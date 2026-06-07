import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../dataconnect_generated/default.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isSignedIn => currentUser != null;

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
  }
}
