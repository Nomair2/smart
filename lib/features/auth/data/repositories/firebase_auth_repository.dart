import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase-backed implementation of [AuthRepository].
///
/// Firebase Auth signs in with an email/password pair, but the UI only
/// collects a Student ID. To bridge that, every registered user's
/// studentId -> email mapping lives in the `users` Firestore collection
/// (document id = Firebase Auth uid, `studentId` kept as a queryable
/// field), and [login] / [resetPassword] resolve the email from that
/// collection before calling FirebaseAuth.
///
/// Firestore document shape (collection `users`), mirroring the "Table
/// users" design in the project report minus `password_hash` — Firebase
/// Auth owns the password itself, so storing a second copy of it would
/// only be a liability:
///   studentId, fullName, universityEmail, college, role, isActive, createdAt
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  static const _usersCollection = 'users';

  @override
  Future<void> login({required String studentId, required String password}) async {
    final email = await _resolveEmail(studentId);
    if (email == null) {
      throw const AuthFailure('No account found for that student ID.');
    }

    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_loginErrorMessage(e));
    }
  }

  @override
  Future<void> register({
    required String studentId,
    required String fullName,
    required String universityEmail,
    required String password,
    required String college,
  }) async {
    final existing = await _firestore
        .collection(_usersCollection)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw const AuthFailure('An account already exists for that student ID.');
    }

    final fb.UserCredential credential;
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: universityEmail,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_registerErrorMessage(e));
    }

    try {
      await credential.user?.updateDisplayName(fullName);
      await _firestore.collection(_usersCollection).doc(credential.user!.uid).set({
        'studentId': studentId,
        'fullName': fullName,
        'universityEmail': universityEmail,
        'college': college,
        'role': 'student',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // The auth account was created but the profile write failed — delete
      // it so the student isn't left with an account they can't complete
      // and can't re-register (email already-in-use) either.
      await credential.user?.delete();
      throw const AuthFailure('Could not finish creating your account. Please try again.');
    }
  }

  @override
  Future<void> resetPassword({required String studentId}) async {
    final email = await _resolveEmail(studentId);
    if (email == null) {
      throw const AuthFailure('No account found for that student ID.');
    }
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_genericErrorMessage(e));
    }
  }

  @override
  Future<void> signInWithSso() {
    // KKU's University Portal SSO is SAML/OAuth-based and needs a custom
    // identity provider registered with Firebase Auth (or a backend
    // token-exchange endpoint), plus coordination with KKU IT to get client
    // credentials. That's a separate integration effort on its own, so this
    // is intentionally left unimplemented rather than faked with a button
    // that appears to work but doesn't call anything real.
    throw UnimplementedError(
      'University Portal (SSO) sign-in needs a SAML/OAuth provider '
      'registered with Firebase Auth and KKU IT coordination before it '
      'can call a real endpoint.',
    );
  }

  Future<String?> _resolveEmail(String studentId) async {
    final query = await _firestore
        .collection(_usersCollection)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.data()['universityEmail'] as String?;
  }

  String _loginErrorMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid student ID or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact your administrator.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return _genericErrorMessage(e);
    }
  }

  String _registerErrorMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'That university email is already registered.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'invalid-email':
        return "That doesn't look like a valid email address.";
      default:
        return _genericErrorMessage(e);
    }
  }

  String _genericErrorMessage(fb.FirebaseAuthException e) {
    if (e.code == 'network-request-failed') {
      return 'No internet connection. Please check your network and try again.';
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }
}
