import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._authRepository) : super(const ForgotPasswordState());

  final AuthRepository _authRepository;

  void studentIdChanged(String value) {
    emit(state.copyWith(studentId: value, studentIdError: _validateStudentId(value)));
  }

  Future<void> submitted() async {
    final studentIdError = _validateStudentId(state.studentId);
    if (studentIdError != null) {
      emit(state.copyWith(studentIdError: studentIdError));
      return;
    }

    emit(state.copyWith(status: ForgotPasswordStatus.submitting, errorMessage: null));

    try {
      await _authRepository.resetPassword(studentId: state.studentId.trim());
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: e is AuthFailure ? e.message : 'Could not send the reset email. Please try again.',
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
}
