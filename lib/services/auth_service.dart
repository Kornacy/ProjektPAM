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

  // ─── Logowanie przez Google ────────────────────────────────────────────────
Future<void> initialize() async{
  await _googleSignIn.initialize(
    // TODO:uzupełnić
    //clientId
    serverClientId: '1090813821582-udqltqne0fbfii0pimaauh1utmos96rq.apps.googleusercontent.com'
  );
  _googleSignIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);
  _googleSignIn.attemptLightweightAuthentication();
} 
Future<void> singInWithGoogle() async{
  await _googleSignIn.authenticate();
}
Future<void> signOut() async{
  await Future.wait([
    _firebaseAuth.signOut(),
    _googleSignIn.signOut()
  ]);
}
Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
  if(event is GoogleSignInAuthenticationEventSignIn){
    await _signInToFirebase(event.user);
  }
  else if(event is GoogleSignInAuthenticationEventSignOut){
    await _firebaseAuth.signOut();
  }
}

void _handleAuthenticationError(Object error){
  //TODO dodać logi
}

Future<void> _signInToFirebase(GoogleSignInAccount gAccount) async {
  final GoogleSignInAuthentication gAuth = await gAccount.authentication;
  final OAuthCredential credential = GoogleAuthProvider.credential(
    idToken: gAuth.idToken
  );
  final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
  final User? user = userCredential.user;

  if(user == null) return;
  await _upsertUser(user);
}

Future<void> _upsertUser(User user) async {
  await DefaultConnector.instance.upsertUser(
    email: user.email ?? '')
    .username(user.displayName)
    .photoUrl(user.photoURL)
    .execute();
}
}