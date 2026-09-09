import 'package:flutter/material.dart';

import '../utils/password_strength.dart';

/// Password input with a visibility toggle and an optional live strength
/// meter (pass [strength] only on the register screen — login doesn't need it).
class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.isVisible,
    required this.onVisibilityToggled,
    this.errorText,
    this.strength,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool isVisible;
  final VoidCallback onVisibilityToggled;
  final String? errorText;
  final PasswordStrength? strength;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSWORD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: !isVisible,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: Colors.grey[500]),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.grey[500],
                ),
                onPressed: onVisibilityToggled,
              ),
              filled: true,
              fillColor: const Color(0xFFF4F6F5),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: errorText != null
                    ? const BorderSide(color: Color(0xFFE0574C))
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1E5B3D), width: 1.5),
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(errorText!, style: const TextStyle(fontSize: 12, color: Color(0xFFE0574C))),
          ],
          if (strength != null && controller.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: strength!.value,
                minHeight: 5,
                backgroundColor: const Color(0xFFE9ECEB),
                valueColor: AlwaysStoppedAnimation(strength!.color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strength!.label,
              style: TextStyle(fontSize: 11.5, color: strength!.color, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
