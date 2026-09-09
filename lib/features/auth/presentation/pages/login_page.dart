import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/auth_gradient_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/primary_auth_button.dart';
import '../widgets/sso_button.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context.read<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<LoginCubit, LoginState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == LoginStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == LoginStatus.success) {
            // TODO: replace with the real post-login route once it exists.
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthGradientHeader(
                    title: 'Welcome Back',
                    subtitle: 'Sign in to continue navigating',
                    emoji: '👋',
                  ),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTextField(
                            label: 'Student ID Number',
                            hint: 'e.g. 441234567',
                            icon: Icons.tag_rounded,
                            controller: _studentIdController,
                            keyboardType: TextInputType.number,
                            errorText: state.studentIdError,
                            onChanged: cubit.studentIdChanged,
                          ),
                          PasswordField(
                            controller: _passwordController,
                            hint: 'Enter your password',
                            isVisible: state.isPasswordVisible,
                            onVisibilityToggled: cubit.passwordVisibilityToggled,
                            errorText: state.passwordError,
                            onChanged: cubit.passwordChanged,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1E5B3D),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          PrimaryAuthButton(
                            label: 'Login',
                            isLoading: state.status == LoginStatus.submitting,
                            onPressed: state.isValid ? cubit.submitted : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFFE4E8E6))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'or sign in with',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFFE4E8E6))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SsoButton(
                            label: 'University Portal (SSO)',
                            onPressed: cubit.ssoRequested,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                children: [
                                  const TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    text: 'Register',
                                    style: const TextStyle(
                                      color: Color(0xFF1E5B3D),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          Navigator.of(context).pushReplacementNamed('/register'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
