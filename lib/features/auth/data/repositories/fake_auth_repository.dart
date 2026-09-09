import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login({
    required String studentId,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (password.length < 4) {
      throw Exception('Invalid credentials');
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
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> signInWithSso() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
