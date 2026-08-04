import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String? name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInAnonymously();
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? resendToken,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String errorMessage) verificationFailed,
  });
  Future<UserModel> signInWithPhoneNumber(String verificationId, String smsCode);
  Future<void> deleteAccount();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<UserModel> reloadUser();
}

class FirebaseAuthDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseAuthDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) throw Exception('User not found');
    return _mapFirebaseUser(credential.user!);
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String? name) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) throw Exception('User creation failed');
    
    if (name != null) {
      await credential.user!.updateDisplayName(name);
    }
    
    return _mapFirebaseUser(credential.user!);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user != null ? _mapFirebaseUser(user) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges => 
      _firebaseAuth.authStateChanges().map((user) => user != null ? _mapFirebaseUser(user) : null);

  @override
  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google Sign-In cancelled');

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user == null) throw Exception('Google Sign-In failed');
    
    return _mapFirebaseUser(userCredential.user!);
  }

  @override
  Future<UserModel> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    if (credential.user == null) throw Exception('Anonymous sign in failed');
    return _mapFirebaseUser(credential.user!);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? resendToken,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String errorMessage) verificationFailed,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Verification failed');
      },
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Future<UserModel> signInWithPhoneNumber(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final authResult = await _firebaseAuth.signInWithCredential(credential);
    if (authResult.user == null) throw Exception('Phone sign in failed');
    return _mapFirebaseUser(authResult.user!);
  }

  @override
  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser?.delete();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  @override
  Future<UserModel> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User session lost');
    return _mapFirebaseUser(user);
  }

  UserModel _mapFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }
}
