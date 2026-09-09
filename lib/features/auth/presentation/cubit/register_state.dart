import 'package:equatable/equatable.dart';

import '../utils/password_strength.dart';

enum RegisterStatus { initial, submitting, success, failure }

const Object _unset = Object();

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.initial,
    this.studentId = '',
    this.fullName = '',
    this.universityEmail = '',
    this.password = '',
    this.college,
    this.isPasswordVisible = false,
    this.studentIdError,
    this.fullNameError,
    this.emailError,
    this.passwordError,
    this.collegeError,
    this.errorMessage,
  });

  final RegisterStatus status;
  final String studentId;
  final String fullName;
  final String universityEmail;
  final String password;
  final String? college;
  final bool isPasswordVisible;
  final String? studentIdError;
  final String? fullNameError;
  final String? emailError;
  final String? passwordError;
  final String? collegeError;
  final String? errorMessage;

  PasswordStrength get passwordStrength => calculatePasswordStrength(password);

  bool get isValid =>
      studentId.trim().isNotEmpty &&
      fullName.trim().isNotEmpty &&
      universityEmail.trim().isNotEmpty &&
      password.isNotEmpty &&
      college != null &&
      studentIdError == null &&
      fullNameError == null &&
      emailError == null &&
      passwordError == null &&
      collegeError == null;

  RegisterState copyWith({
    RegisterStatus? status,
    String? studentId,
    String? fullName,
    String? universityEmail,
    String? password,
    Object? college = _unset,
    bool? isPasswordVisible,
    Object? studentIdError = _unset,
    Object? fullNameError = _unset,
    Object? emailError = _unset,
    Object? passwordError = _unset,
    Object? collegeError = _unset,
    Object? errorMessage = _unset,
  }) {
    return RegisterState(
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      universityEmail: universityEmail ?? this.universityEmail,
      password: password ?? this.password,
      college: identical(college, _unset) ? this.college : college as String?,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      studentIdError:
          identical(studentIdError, _unset) ? this.studentIdError : studentIdError as String?,
      fullNameError:
          identical(fullNameError, _unset) ? this.fullNameError : fullNameError as String?,
      emailError: identical(emailError, _unset) ? this.emailError : emailError as String?,
      passwordError:
          identical(passwordError, _unset) ? this.passwordError : passwordError as String?,
      collegeError:
          identical(collegeError, _unset) ? this.collegeError : collegeError as String?,
      errorMessage:
          identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        studentId,
        fullName,
        universityEmail,
        password,
        college,
        isPasswordVisible,
        studentIdError,
        fullNameError,
        emailError,
        passwordError,
        collegeError,
        errorMessage,
      ];
}
