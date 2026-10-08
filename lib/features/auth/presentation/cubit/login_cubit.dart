import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  void identifierChanged(String value) {
    emit(
      state.copyWith(
        identifier: value,
        identifierError: _validateIdentifier(value),
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
    final identifierError = _validateIdentifier(state.identifier);
    final passwordError = _validatePassword(state.password);

    if (identifierError != null || passwordError != null) {
      emit(
        state.copyWith(
          identifierError: identifierError,
          passwordError: passwordError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    try {
      await _authRepository.login(
        identifier: state.identifier.trim(),
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
              : 'Invalid student ID/email or password. Please try again.',
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

  /// Accepts either shape the single login field can hold — a plain
  /// student-ID number, or an email address — and validates whichever one
  /// the user appears to be typing. The '@' check is the same signal
  /// `FirebaseAuthRepository.login` uses to tell them apart, so a value
  /// that passes here is guaranteed to be resolved the way the user meant.
  String? _validateIdentifier(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Student ID or email is required';
    if (trimmed.contains('@')) {
      if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(trimmed)) {
        return 'Enter a valid email address';
      }
      return null;
    }
    if (!RegExp(r'^\d{6,10}$').hasMatch(trimmed)) {
      return 'Enter a valid student ID (e.g. 441234567) or email';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    return null;
  }
}
