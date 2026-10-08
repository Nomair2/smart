import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

enum PasswordStrength { weak, fair, good, strong }

extension PasswordStrengthX on PasswordStrength {
  // Only one call site (password_field.dart), so taking l10n directly
  // instead of a BuildContext is a small, low-risk way to localize this
  // — unlike SeasonMode.label, which has enough call sites across other
  // features that converting it was left out of scope for now.
  String label(AppLocalizations l10n) {
    switch (this) {
      case PasswordStrength.weak:
        return l10n.passwordStrengthWeak;
      case PasswordStrength.fair:
        return l10n.passwordStrengthFair;
      case PasswordStrength.good:
        return l10n.passwordStrengthGood;
      case PasswordStrength.strong:
        return l10n.passwordStrengthStrong;
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.weak:
        return const Color(0xFFE0574C);
      case PasswordStrength.fair:
        return const Color(0xFFE0A83C);
      case PasswordStrength.good:
        return const Color(0xFF7FB069);
      case PasswordStrength.strong:
        return const Color(0xFF1E5B3D);
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.fair:
        return 0.5;
      case PasswordStrength.good:
        return 0.75;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}

/// Simple heuristic: length + character-class variety. Good enough for
/// client-side UX feedback — the server should still enforce a real policy.
PasswordStrength calculatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.weak;

  int score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$&*~%^()_\-+=]').hasMatch(password)) score++;
  if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) {
    score++;
  }

  if (score <= 1) return PasswordStrength.weak;
  if (score == 2) return PasswordStrength.fair;
  if (score <= 4) return PasswordStrength.good;
  return PasswordStrength.strong;
}
