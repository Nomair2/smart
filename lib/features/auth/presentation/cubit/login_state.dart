import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user_role.dart';

enum LoginStatus { initial, submitting, success, failure }

/// Sentinel used so `copyWith` can tell "leave this field alone" apart from
/// "set this field to null" for the nullable error/message fields.
const Object _unset = Object();

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.identifier = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.identifierError,
    this.passwordError,
    this.errorMessage,
    this.role,
  });

  final LoginStatus status;

  /// Whatever's typed into the single login field — a student ID or an
  /// email. See `AuthRepository.login`'s doc comment for how the two are
  /// told apart.
  final String identifier;
  final String password;
  final bool isPasswordVisible;
  final String? identifierError;
  final String? passwordError;
  final String? errorMessage;
  final AppUserRole? role;

  bool get isValid =>
      identifier.trim().isNotEmpty &&
      password.isNotEmpty &&
      identifierError == null &&
      passwordError == null;

  LoginState copyWith({
    LoginStatus? status,
    String? identifier,
    String? password,
    bool? isPasswordVisible,
    Object? identifierError = _unset,
    Object? passwordError = _unset,
    Object? errorMessage = _unset,
    Object? role = _unset,
  }) {
    return LoginState(
      status: status ?? this.status,
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      identifierError: identical(identifierError, _unset)
          ? this.identifierError
          : identifierError as String?,
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
    identifier,
    password,
    isPasswordVisible,
    identifierError,
    passwordError,
    errorMessage,
    role,
  ];
}
