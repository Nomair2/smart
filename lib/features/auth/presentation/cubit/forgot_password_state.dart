import 'package:equatable/equatable.dart';

enum ForgotPasswordStatus { initial, submitting, success, failure }

const Object _unset = Object();

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.studentId = '',
    this.studentIdError,
    this.errorMessage,
  });

  final ForgotPasswordStatus status;
  final String studentId;
  final String? studentIdError;
  final String? errorMessage;

  bool get isValid => studentId.trim().isNotEmpty && studentIdError == null;

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? studentId,
    Object? studentIdError = _unset,
    Object? errorMessage = _unset,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      studentIdError:
          identical(studentIdError, _unset) ? this.studentIdError : studentIdError as String?,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, studentId, studentIdError, errorMessage];
}
