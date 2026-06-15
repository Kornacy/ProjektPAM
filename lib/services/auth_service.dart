import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../dataconnect_generated/default.dart';
import 'notification_service.dart';
import 'storage_service.dart';

typedef DeleteAccountMutation = Future<DeleteAccountData> Function();

class AuthService {
  AuthService._({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    DeleteAccountMutation? deleteAccountMutation,
    StorageService? storageService,
  })  : _firebaseAuthOverride = firebaseAuth,
        _googleSignInOverride = googleSignIn,
        _deleteAccountMutation = deleteAccountMutation,
        _storageService = storageService ?? StorageService.instance;

  static final AuthService instance = AuthService._();

  @visibleForTesting
  factory AuthService.forTesting({
    FirebaseAuth? firebaseAuth,
    DeleteAccountMutation? deleteAccountMutation,
    StorageService? storageService,
  }) =>
      AuthService._(
        firebaseAuth: firebaseAuth,
        deleteAccountMutation: deleteAccountMutation,
        storageService: storageService,
      );

  final FirebaseAuth? _firebaseAuthOverride;
  final GoogleSignIn? _googleSignInOverride;
  final DeleteAccountMutation? _deleteAccountMutation;
  final StorageService _storageService;

  FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ?? FirebaseAuth.instance;

  GoogleSignIn get _googleSignIn =>
      _googleSignInOverride ?? GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isSignedIn => currentUser != null;

  Future<void> ensureUserProfile() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Musisz być zalogowany, aby wykonać tę akcję.');
    }
    await _upsertUser(user);
  }

  Future<void> initialize() async {
    await _googleSignIn.initialize(
      serverClientId:
          '1090813821582-udqltqne0fbfii0pimaauh1utmos96rq.apps.googleusercontent.com',
    );
    _googleSignIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);

    // Firebase utrzymuje sesję — nie uruchamiaj lekkiego logowania Google,
    // bo na Androidzie może to wyświetlić arkusz wyboru konta przy każdym starcie.
    if (_firebaseAuth.currentUser == null) {
      _googleSignIn.attemptLightweightAuthentication();
    }
  }

  /// Czeka na pierwszą emisję stanu auth (przywrócenie sesji z pamięci).
  Future<void> waitForAuthReady() {
    return _firebaseAuth.authStateChanges().first;
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) await _upsertUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(mapAuthError(e));
    }
  }

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) await _upsertUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(mapAuthError(e));
    }
  }

  Future<void> signInWithGoogle() async {
    await _googleSignIn.authenticate();
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Usuwa dane użytkownika z PostgreSQL, pliki ze Storage oraz konto Firebase Auth.
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Musisz być zalogowany, aby usunąć konto.');
    }

    final uid = user.uid;

    final result = await _deleteAccountMutationImpl();
    if (result.user_delete == null) {
      throw Exception('Nie udało się usunąć konta z bazy danych.');
    }

    await _storageService.deleteAllUserPhotos(uid);

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Ze względów bezpieczeństwa wyloguj się, zaloguj ponownie '
          'i spróbuj usunąć konto jeszcze raz.',
        );
      }
      throw Exception(mapAuthError(e));
    }

    await _googleSignIn.signOut();
  }

  Future<DeleteAccountData> _deleteAccountMutationImpl() {
    final deleteAccount = _deleteAccountMutation;
    if (deleteAccount != null) {
      return deleteAccount();
    }
    return DefaultConnector.instance
        .deleteAccount()
        .execute()
        .then((result) => result.data);
  }

  static String mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Nieprawidłowy e-mail lub hasło.';
      case 'email-already-in-use':
        return 'Ten adres e-mail jest już zarejestrowany.';
      case 'user-not-found':
        return 'Nie znaleziono użytkownika o podanym adresie e-mail.';
      case 'weak-password':
        return 'Hasło jest zbyt słabe (min. 8 znaków).';
      case 'invalid-email':
        return 'Nieprawidłowy adres e-mail.';
      case 'too-many-requests':
        return 'Zbyt wiele prób. Spróbuj ponownie później.';
      default:
        return e.message ?? 'Wystąpił błąd uwierzytelniania.';
    }
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      await _signInToFirebase(event.user);
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      final user = _firebaseAuth.currentUser;
      final signedInWithGoogle = user?.providerData.any(
            (info) => info.providerId == 'google.com',
          ) ??
          false;
      if (signedInWithGoogle) {
        await _firebaseAuth.signOut();
      }
    }
  }

  void _handleAuthenticationError(Object error) {
    // Ignorowane przy lekkim logowaniu w tle.
  }

  Future<void> _signInToFirebase(GoogleSignInAccount gAccount) async {
    final GoogleSignInAuthentication gAuth = gAccount.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
    );
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user == null) return;
    await _upsertUser(user);
  }

  Future<void> _upsertUser(User user) async {
    await DefaultConnector.instance
        .upsertUser(email: user.email ?? '')
        .username(user.displayName ?? user.email?.split('@').first ?? 'Użytkownik')
        .photoUrl(user.photoURL ?? '')
        .execute();
    await NotificationService.instance.syncToken();
  }
}
