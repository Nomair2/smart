import 'package:flutter/material.dart';

enum PasswordStrength { weak, fair, good, strong }

extension PasswordStrengthX on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak — try a longer password';
      case PasswordStrength.fair:
        return 'Fair — add numbers to strengthen';
      case PasswordStrength.good:
        return 'Good — add a symbol for extra strength';
      case PasswordStrength.strong:
        return 'Strong password';
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
