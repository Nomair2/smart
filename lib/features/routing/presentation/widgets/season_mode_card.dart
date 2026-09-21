import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_mode.dart';

class SeasonModeCard extends StatelessWidget {
  const SeasonModeCard({super.key, required this.mode, required this.selected, required this.onTap});

  final SeasonMode mode;
  final bool selected;
  final VoidCallback onTap;

  static const Color primaryGreen = Color(0xFF1E5B3D);

  String get _emoji {
    switch (mode) {
      case SeasonMode.summer:
        return '\u2600\ufe0f';
      case SeasonMode.winter:
        return '\u2744\ufe0f';
      case SeasonMode.auto:
        return '\ud83c\udf24\ufe0f';
    }
  }

  String get _subtitle {
    switch (mode) {
      case SeasonMode.summer:
        return 'Shaded paths';
      case SeasonMode.winter:
        return 'Sun-exposed paths';
      case SeasonMode.auto:
        return 'Weather-adaptive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF3EE) : const Color(0xFFF6F8F7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? primaryGreen : Colors.transparent, width: 1.5),
          ),
          child: Column(
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(mode.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? primaryGreen : Colors.black87)),
              const SizedBox(height: 2),
              Text(_subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}
