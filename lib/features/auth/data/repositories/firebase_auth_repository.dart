import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/app_user_role.dart';

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
///   studentId, fullName, email, college, role, isActive, createdAt
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  static const _usersCollection = 'users';
  static const _adminsCollection = 'admins';

  @override
  Future<void> login({
    required String studentId,
    required String password,
  }) async {
    print("1");
    final email = await _resolveEmail(studentId);
    print(email);
    print("2");
    print(email);
    if (email == null) {
      throw const AuthFailure('No account found for that student ID.');
    }

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_loginErrorMessage(e));
    }
  }

  @override
  Future<void> register({
    required String studentId,
    required String fullName,
    required String email,
    required String password,
    required String college,
  }) async {
    print("in firebase_repo");
    final existing = await _firestore
        .collection(_usersCollection)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    print("1");
    if (existing.docs.isNotEmpty) {
      throw const AuthFailure('An account already exists for that student ID.');
    }

    final fb.UserCredential credential;
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      print("the 1 error : ${e.toString()}");
      throw AuthFailure(_registerErrorMessage(e));
    }

    try {
      print("4");
      await credential.user?.updateDisplayName(fullName);
      await _firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .set({
            'studentId': studentId,
            'fullName': fullName,
            'email': email,
            'college': college,
            'role': 'student',
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print("the 1 error : ${e.toString()}");
      // The auth account was created but the profile write failed — delete
      // it so the student isn't left with an account they can't complete
      // and can't re-register (email already-in-use) either.
      await credential.user?.delete();
      throw const AuthFailure(
        'Could not finish creating your account. Please try again.',
      );
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

  @override
  Future<AppUserRole> currentUserRole() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw const AuthFailure('No signed-in user to check a role for.');
    }

    final adminDoc = await _firestore
        .collection(_adminsCollection)
        .doc(uid)
        .get();
    if (adminDoc.exists) return AppUserRole.admin;

    // Every account created through register() has a `users/{uid}` doc, so
    // this is the expected path for ordinary students. If neither doc
    // exists (e.g. the account was created directly in the Firebase
    // console without a matching Firestore doc), default to student rather
    // than throwing — an admin who forgot the Firestore doc will notice
    // immediately from missing permissions, which is a safer failure mode
    // than locking a real student out over a data-entry gap.
    return AppUserRole.student;
  }

  Future<String?> _resolveEmail(String studentId) async {
    final query = await _firestore
        .collection(_adminsCollection)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      final query2 = await _firestore
          .collection(_usersCollection)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      print(query2.docs.isEmpty);
      print(query2.docs.first.data());
      print(query2.docs.length);
      if (query2.docs.isEmpty) return null;

      return query2.docs.first.data()['email'] as String?;
    }
    // print(query2.docs.first.data()['email']);

    print("12");
    return query.docs.first.data()['email'] as String?;
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
        return 'That  email is already registered.';
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
