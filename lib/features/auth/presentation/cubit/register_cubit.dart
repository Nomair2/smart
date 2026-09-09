import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._authRepository) : super(const RegisterState());

  final AuthRepository _authRepository;

  void studentIdChanged(String value) {
    emit(state.copyWith(studentId: value, studentIdError: _validateStudentId(value)));
  }

  void fullNameChanged(String value) {
    emit(state.copyWith(fullName: value, fullNameError: _validateFullName(value)));
  }

  void emailChanged(String value) {
    emit(state.copyWith(universityEmail: value, emailError: _validateEmail(value)));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, passwordError: _validatePassword(value)));
  }

  void collegeChanged(String? value) {
    emit(state.copyWith(
      college: value,
      collegeError: value == null ? 'Please select your college' : null,
    ));
  }

  void passwordVisibilityToggled() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> submitted() async {
    final studentIdError = _validateStudentId(state.studentId);
    final fullNameError = _validateFullName(state.fullName);
    final emailError = _validateEmail(state.universityEmail);
    final passwordError = _validatePassword(state.password);
    final collegeError = state.college == null ? 'Please select your college' : null;

    final hasErrors = [studentIdError, fullNameError, emailError, passwordError, collegeError]
        .any((e) => e != null);

    if (hasErrors) {
      emit(state.copyWith(
        studentIdError: studentIdError,
        fullNameError: fullNameError,
        emailError: emailError,
        passwordError: passwordError,
        collegeError: collegeError,
      ));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.submitting, errorMessage: null));

    try {
      await _authRepository.register(
        studentId: state.studentId.trim(),
        fullName: state.fullName.trim(),
        universityEmail: state.universityEmail.trim(),
        password: state.password,
        college: state.college!,
      );
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: e is AuthFailure ? e.message : 'Could not create your account. Please try again.',
      ));
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

  String? _validateFullName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Full name is required';
    if (trimmed.split(RegExp(r'\s+')).length < 2) return 'Enter your first and last name';
    return null;
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return 'University email is required';
    if (!trimmed.endsWith('@kku.edu.sa')) return 'Use your KKU university email (id@kku.edu.sa)';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Use at least 8 characters';
    return null;
  }
}
