import '../entities/app_user_role.dart';

/// Contract the presentation layer depends on. Implement this in the data
/// layer (e.g. `FirebaseAuthRepository`) and provide it above `MaterialApp`
/// with `RepositoryProvider<AuthRepository>`.
///
/// NOTE for the Firebase implementation: FirebaseAuth signs in with an
/// email/password pair, not a student ID directly. `login()` takes a
/// studentId because that's what the design collects, so the concrete
/// implementation will need to either:
///   1. look up the student's email in Firestore by studentId, then call
///      `signInWithEmailAndPassword`, or
///   2. store users under a synthetic email like `<studentId>@smartpath.app`
///      at registration time and sign in with that directly.
/// Option 1 keeps the real university email as the source of truth and is
/// what `register()` below assumes.
abstract class AuthRepository {
  Future<void> login({required String studentId, required String password});

  Future<void> register({
    required String studentId,
    required String fullName,
    required String email,
    required String password,
    required String college,
  });

  Future<void> signInWithSso();

  /// Sends a password-reset email for the account matching [studentId].
  /// Implementations resolve the underlying email the same way [login] does.
  Future<void> resetPassword({required String studentId});

  /// Which role the *currently signed-in* Firebase Auth user has. Call this
  /// right after [login] succeeds, or on app startup once
  /// `authStateChanges` confirms a user is already signed in. Throws if
  /// nobody is currently signed in.
  Future<AppUserRole> currentUserRole();
}
