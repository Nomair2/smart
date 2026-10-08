import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../../core/localization/app_localizations.dart';

class SeasonModeCard extends StatelessWidget {
  const SeasonModeCard({super.key, required this.mode, required this.selected, required this.onTap});

  final SeasonMode mode;
  final bool selected;
  final VoidCallback onTap;

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

  String _subtitle(AppLocalizations l10n) {
    switch (mode) {
      case SeasonMode.summer:
        return l10n.shadedPaths;
      case SeasonMode.winter:
        return l10n.sunExposedPaths;
      case SeasonMode.auto:
        return l10n.weatherAdaptive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            // Was hardcoded Color(0xFFEAF3EE)/Color(0xFFF6F8F7) — theme
            // tokens so the unselected card doesn't match the scaffold
            // in dark mode, and selected keeps a visible accent either way.
            color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? colorScheme.primary : Colors.transparent, width: 1.5),
          ),
          child: Column(
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(mode.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? colorScheme.primary : null)),
              const SizedBox(height: 2),
              Text(_subtitle(l10n),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}
