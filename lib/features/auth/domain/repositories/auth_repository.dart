import '../entities/app_user_role.dart';

/// Contract the presentation layer depends on. Implement this in the data
/// layer (e.g. `FirebaseAuthRepository`) and provide it above `MaterialApp`
/// with `RepositoryProvider<AuthRepository>`.
///
/// NOTE for the Firebase implementation: FirebaseAuth signs in with an
/// email/password pair, not a student ID directly. `login()` takes a single
/// [identifier] field that accepts either, so the concrete implementation
/// needs to tell them apart and, for a student ID, look up the matching
/// email in Firestore before calling `signInWithEmailAndPassword` — see the
/// doc comment on `login` below. `register()` still assumes the real
/// university email is the source of truth in Firestore.
abstract class AuthRepository {
  /// [identifier] is whatever the student typed into the one login field —
  /// either their student ID (digits) or their university email. The
  /// implementation tells the two apart (an email always contains '@', and
  /// a student ID never does) and resolves either one to the Firebase Auth
  /// email FirebaseAuth actually needs.
  Future<void> login({required String identifier, required String password});

  Future<void> register({
    required String studentId,
    required String fullName,
    required String email,
    required String password,
    required String college,
  });

  Future<void> signInWithSso();

  /// Sends a password-reset email for the account matching [studentId].
  /// Unlike [login], this still only accepts a student ID, not an email —
  /// extend this the same way if that field ever needs the same flexibility.
  Future<void> resetPassword({required String studentId});

  /// Which role the *currently signed-in* Firebase Auth user has. Call this
  /// right after [login] succeeds, or on app startup once
  /// `authStateChanges` confirms a user is already signed in. Throws if
  /// nobody is currently signed in.
  Future<AppUserRole> currentUserRole();
}
