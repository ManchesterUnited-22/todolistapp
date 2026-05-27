import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_app/views/login_viewmodel.dart';
import 'package:smart_app/views/register_viewmodel.dart';

export 'package:firebase_auth/firebase_auth.dart';

Future<void> initializeFirebase() async {
  // Firebase is now initialized in main.dart with proper options
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  Future<void>? _googleSignInInitialization;

  Future<void> _ensureGoogleSignInInitialized() {
    // Some google_sign_in versions expose different APIs; avoid calling
    // package-specific initialize here and just return a resolved future.
    return _googleSignInInitialization ??= Future.value();
  }

  Future<UserCredential> signInWithGoogle() async {
    debugPrint('Google sign-in: starting');

    if (kIsWeb) {
      final credential = await _auth.signInWithPopup(GoogleAuthProvider());
      debugPrint('Google sign-in: web success ${credential.user?.uid}');
      return credential;
    }

    await _ensureGoogleSignInInitialized();

    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    debugPrint('Google sign-in: success ${userCredential.user?.uid}');
    return userCredential;
  }

  Future<void> saveLoginRecord(LoginViewModel loginData) async {
    if (loginData.uid.trim().isEmpty) {
      throw ArgumentError('loginData.uid must not be empty');
    }

    debugPrint('Login: writing login record to Firestore');
    try {
      await _firestore
          .collection('login')
          .doc(loginData.uid)
          .set(loginData.toFirestoreMap());
    } on FirebaseException catch (error) {
      debugPrint(
        'Login firestore error: ${error.plugin} ${error.code} ${error.message}',
      );
      rethrow;
    }
  }

  Future<UserCredential> loginUser(LoginViewModel loginData) async {
    debugPrint('Login: signing in user');
    late final UserCredential credential;

    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: loginData.email.trim(),
        password: loginData.password,
      );
    } on FirebaseAuthException catch (error) {
      debugPrint('Login auth error: ${error.code} ${error.message}');
      rethrow;
    }

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Could not sign in user.',
      );
    }

    await saveLoginRecord(loginData.copyWith(uid: user.uid));

    return credential;
  }

  Future<UserCredential> registerUser(RegisterViewModel registerData) async {
    debugPrint('Register: creating auth user');
    late final UserCredential credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: registerData.email.trim(),
        password: registerData.password,
      );
    } on FirebaseAuthException catch (error) {
      debugPrint('Register auth error: ${error.code} ${error.message}');
      rethrow;
    }

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Could not create user account.',
      );
    }

    debugPrint('Register: updating display name');
    try {
      await user.updateDisplayName(registerData.displayName.trim());
    } on FirebaseException catch (error) {
      debugPrint(
        'Register profile error: ${error.plugin} ${error.code} ${error.message}',
      );
      rethrow;
    }

    debugPrint('Register: writing user profile to Firestore');
    try {
      await _firestore
          .collection('register')
          .doc(user.uid)
          .set(
            registerData
                .copyWith(uid: user.uid)
                .toFirestoreMap(uidValue: user.uid),
          );
    } on FirebaseException catch (error) {
      debugPrint(
        'Register firestore error: ${error.plugin} ${error.code} ${error.message}',
      );
      rethrow;
    }

    return credential;
  }
}
