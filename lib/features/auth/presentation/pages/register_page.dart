import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
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

  @override
  void dispose() {
    _studentIdController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickCollege(BuildContext context, RegisterCubit cubit, List<String> colleges) async {
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
            children: colleges
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
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
                  AuthGradientHeader(
                    title: l10n.createAccount,
                    subtitle: l10n.joinMasarFree,
                    emoji: '✨',
                  ),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const StepProgressBar(currentStep: 1, totalSteps: 3),
                          const SizedBox(height: 24),
                          AuthTextField(
                            label: l10n.studentIdNumber,
                            hint: l10n.studentIdHint,
                            icon: Icons.tag_rounded,
                            controller: _studentIdController,
                            keyboardType: TextInputType.number,
                            errorText: state.studentIdError,
                            onChanged: cubit.studentIdChanged,
                          ),
                          AuthTextField(
                            label: l10n.fullNameLabel,
                            hint: l10n.fullNameHint,
                            icon: Icons.person_outline_rounded,
                            controller: _fullNameController,
                            keyboardType: TextInputType.name,
                            errorText: state.fullNameError,
                            onChanged: cubit.fullNameChanged,
                          ),
                          AuthTextField(
                            label: l10n.emailLabel,
                            hint: l10n.emailHint,
                            icon: Icons.mail_outline_rounded,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            errorText: state.emailError,
                            onChanged: cubit.emailChanged,
                          ),
                          PasswordField(
                            controller: _passwordController,
                            hint: l10n.createStrongPassword,
                            isVisible: state.isPasswordVisible,
                            onVisibilityToggled:
                                cubit.passwordVisibilityToggled,
                            errorText: state.passwordError,
                            strength: state.passwordStrength,
                            onChanged: cubit.passwordChanged,
                          ),
                          Text(
                            l10n.collegeMajorLabel,
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
                            onTap: () => _pickCollege(context, cubit, l10n.colleges),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                      state.college ?? l10n.selectYourCollege,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: state.college != null
                                            ? null
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
                            label: l10n.createAccount,
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
                                  TextSpan(text: l10n.alreadyHaveAccount),
                                  TextSpan(
                                    text: l10n.login,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
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
