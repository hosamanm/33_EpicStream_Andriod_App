import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

/// Service class that interacts directly with Firebase Authentication.
/// Acts as the Remote Data Source in Clean Architecture.
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final Logger _logger;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    required Logger logger,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _logger = logger;

  // --- Email & Password ---

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _logger.e('AuthService: signInWithEmail failed', error: e);
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _logger.e('AuthService: signUpWithEmail failed', error: e);
      rethrow;
    }
  }

  // --- Social Auth ---

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      _logger.e('AuthService: signInWithGoogle failed', error: e);
      rethrow;
    }
  }

  // --- Anonymous Auth ---

  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      _logger.e('AuthService: signInAnonymously failed', error: e);
      rethrow;
    }
  }

  // --- Phone Auth ---

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? resendToken,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: resendToken,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      _logger.e('AuthService: verifyPhoneNumber failed', error: e);
      rethrow;
    }
  }

  Future<UserCredential> signInWithPhoneCredential(AuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      _logger.e('AuthService: signInWithPhoneCredential failed', error: e);
      rethrow;
    }
  }

  // --- Account Management ---

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _logger.e('AuthService: signOut failed', error: e);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      _logger.e('AuthService: deleteAccount failed', error: e);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _logger.e('AuthService: sendPasswordResetEmail failed', error: e);
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      _logger.e('AuthService: sendEmailVerification failed', error: e);
      rethrow;
    }
  }

  // --- User State ---

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      _logger.e('AuthService: reloadUser failed', error: e);
      rethrow;
    }
  }
}
