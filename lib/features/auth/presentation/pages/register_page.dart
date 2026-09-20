import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';
import '../widgets/auth_gradient_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/primary_auth_button.dart';
import '../widgets/step_progress_bar.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context.read<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _studentIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // TODO: replace with the real college/major list (or fetch remotely).
  static const _colleges = [
    'College of Computer Science',
    'College of Engineering',
    'College of Medicine',
    'College of Business',
    'College of Science',
    'College of Education',
  ];

  @override
  void dispose() {
    _studentIdController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickCollege(BuildContext context, RegisterCubit cubit) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: _colleges
                .map(
                  (college) => ListTile(
                    title: Text(college),
                    onTap: () => Navigator.of(sheetContext).pop(college),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (selected != null) cubit.collegeChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == RegisterStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == RegisterStatus.success) {
            // TODO: replace with the real post-registration route.
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        builder: (context, state) {
          final cubit = context.read<RegisterCubit>();
          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthGradientHeader(
                    title: 'Create Account',
                    subtitle: "Join Masar KKU — it's free",
                    emoji: '✨',
                  ),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const StepProgressBar(currentStep: 1, totalSteps: 3),
                          const SizedBox(height: 24),
                          AuthTextField(
                            label: 'Student ID Number',
                            hint: 'e.g. 441234567',
                            icon: Icons.tag_rounded,
                            controller: _studentIdController,
                            keyboardType: TextInputType.number,
                            errorText: state.studentIdError,
                            onChanged: cubit.studentIdChanged,
                          ),
                          AuthTextField(
                            label: 'Full Name',
                            hint: 'Your full name',
                            icon: Icons.person_outline_rounded,
                            controller: _fullNameController,
                            keyboardType: TextInputType.name,
                            errorText: state.fullNameError,
                            onChanged: cubit.fullNameChanged,
                          ),
                          AuthTextField(
                            label: 'Email',
                            hint: 'name@gmail.com',
                            icon: Icons.mail_outline_rounded,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            errorText: state.emailError,
                            onChanged: cubit.emailChanged,
                          ),
                          PasswordField(
                            controller: _passwordController,
                            hint: 'Create a strong password',
                            isVisible: state.isPasswordVisible,
                            onVisibilityToggled:
                                cubit.passwordVisibilityToggled,
                            errorText: state.passwordError,
                            strength: state.passwordStrength,
                            onChanged: cubit.passwordChanged,
                          ),
                          Text(
                            'COLLEGE / MAJOR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _pickCollege(context, cubit),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F6F5),
                                borderRadius: BorderRadius.circular(14),
                                border: state.collegeError != null
                                    ? Border.all(color: const Color(0xFFE0574C))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '🎓',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      state.college ?? 'Select your college',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: state.college != null
                                            ? Colors.black87
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey[500],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (state.collegeError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              state.collegeError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE0574C),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          PrimaryAuthButton(
                            label: 'Create Account',
                            isLoading:
                                state.status == RegisterStatus.submitting,
                            onPressed: state.isValid ? cubit.submitted : null,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Already have an account? ',
                                  ),
                                  TextSpan(
                                    text: 'Login',
                                    style: const TextStyle(
                                      color: Color(0xFF1E5B3D),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.of(
                                        context,
                                      ).pushReplacementNamed('/login'),
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
