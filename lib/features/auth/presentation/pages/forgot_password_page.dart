import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/auth_gradient_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_auth_button.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(context.read<AuthRepository>()),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _studentIdController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ForgotPasswordStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<ForgotPasswordCubit>();
          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthGradientHeader(
                    title: l10n.resetPassword,
                    subtitle: l10n.resetPasswordSubtitle,
                    emoji: '🔑',
                  ),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: state.status == ForgotPasswordStatus.success
                          ? _SuccessContent(onBackToLogin: () => Navigator.of(context).pop())
                          : _FormContent(
                              controller: _studentIdController,
                              state: state,
                              cubit: cubit,
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

class _FormContent extends StatelessWidget {
  const _FormContent({required this.controller, required this.state, required this.cubit});

  final TextEditingController controller;
  final ForgotPasswordState state;
  final ForgotPasswordCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.forgotPasswordBody,
          style: TextStyle(fontSize: 13.5, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: l10n.studentIdNumber,
          hint: l10n.studentIdHint,
          icon: Icons.tag_rounded,
          controller: controller,
          keyboardType: TextInputType.number,
          errorText: state.studentIdError,
          onChanged: cubit.studentIdChanged,
        ),
        const SizedBox(height: 8),
        PrimaryAuthButton(
          label: l10n.sendResetLink,
          isLoading: state.status == ForgotPasswordStatus.submitting,
          onPressed: state.isValid ? cubit.submitted : null,
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.onBackToLogin});

  final VoidCallback onBackToLogin;

  static const Color primaryGreen = Color(0xFF1E5B3D);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: const BoxDecoration(color: Color(0xFFEAF3EE), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_rounded, color: primaryGreen, size: 32),
        ),
        Text(
          l10n.checkYourEmail,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.forgotPasswordSuccessBody,
          style: TextStyle(fontSize: 13.5, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 24),
        PrimaryAuthButton(label: l10n.backToLogin, onPressed: onBackToLogin, showArrow: false),
      ],
    );
  }
}
