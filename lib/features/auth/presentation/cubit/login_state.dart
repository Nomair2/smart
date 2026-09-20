import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user_role.dart';

enum LoginStatus { initial, submitting, success, failure }

/// Sentinel used so `copyWith` can tell "leave this field alone" apart from
/// "set this field to null" for the nullable error/message fields.
const Object _unset = Object();

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.studentId = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.studentIdError,
    this.passwordError,
    this.errorMessage,
    this.role,
  });

  final LoginStatus status;
  final String studentId;
  final String password;
  final bool isPasswordVisible;
  final String? studentIdError;
  final String? passwordError;
  final String? errorMessage;
  final AppUserRole? role;

  bool get isValid =>
      studentId.trim().isNotEmpty &&
      password.isNotEmpty &&
      studentIdError == null &&
      passwordError == null;

  LoginState copyWith({
    LoginStatus? status,
    String? studentId,
    String? password,
    bool? isPasswordVisible,
    Object? studentIdError = _unset,
    Object? passwordError = _unset,
    Object? errorMessage = _unset,
    Object? role = _unset,
  }) {
    return LoginState(
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      studentIdError: identical(studentIdError, _unset)
          ? this.studentIdError
          : studentIdError as String?,
      passwordError: identical(passwordError, _unset)
          ? this.passwordError
          : passwordError as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      role: identical(role, _unset) ? this.role : role as AppUserRole?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    studentId,
    password,
    isPasswordVisible,
    studentIdError,
    passwordError,
    errorMessage,
    role,
  ];
}
