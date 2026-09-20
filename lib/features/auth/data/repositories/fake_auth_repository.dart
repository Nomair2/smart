import '../../domain/entities/app_user_role.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  // Test hook: log in with this student ID to exercise the admin route
  // without wiring up Firestore. Anything else is treated as a student.
  static const testAdminStudentId = '000000000';

  String? _signedInStudentId;

  @override
  Future<void> login({
    required String studentId,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (password.length < 4) {
      throw const AuthFailure(
        'Invalid student ID or password. Please try again.',
      );
    }
    _signedInStudentId = studentId;
  }

  @override
  Future<void> register({
    required String studentId,
    required String fullName,
    required String email,
    required String password,
    required String college,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> signInWithSso() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> resetPassword({required String studentId}) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<AppUserRole> currentUserRole() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _signedInStudentId == testAdminStudentId
        ? AppUserRole.admin
        : AppUserRole.student;
  }
}
