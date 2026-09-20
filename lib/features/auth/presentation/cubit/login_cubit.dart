import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  void studentIdChanged(String value) {
    emit(
      state.copyWith(
        studentId: value,
        studentIdError: _validateStudentId(value),
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(password: value, passwordError: _validatePassword(value)),
    );
  }

  void passwordVisibilityToggled() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> submitted() async {
    final studentIdError = _validateStudentId(state.studentId);
    final passwordError = _validatePassword(state.password);

    if (studentIdError != null || passwordError != null) {
      emit(
        state.copyWith(
          studentIdError: studentIdError,
          passwordError: passwordError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    try {
      await _authRepository.login(
        studentId: state.studentId.trim(),
        password: state.password,
      );
      final role = await _authRepository.currentUserRole();
      emit(state.copyWith(status: LoginStatus.success, role: role));
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: e is AuthFailure
              ? e.message
              : 'Invalid student ID or password. Please try again.',
        ),
      );
    }
  }

  Future<void> ssoRequested() async {
    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));
    try {
      await _authRepository.signInWithSso();
      final role = await _authRepository.currentUserRole();
      emit(state.copyWith(status: LoginStatus.success, role: role));
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: e is AuthFailure
              ? e.message
              : 'Could not sign in with the University Portal. Please try again.',
        ),
      );
    }
  }

  String? _validateStudentId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Student ID is required';
    if (!RegExp(r'^\d{6,10}$').hasMatch(trimmed)) {
      return 'Enter a valid student ID (e.g. 441234567)';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    return null;
  }
}
