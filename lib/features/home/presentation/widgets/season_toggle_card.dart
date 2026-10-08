import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class SeasonToggleCard extends StatelessWidget {
  const SeasonToggleCard({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6E3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                const BoxDecoration(color: Color(0xFFF5C542), shape: BoxShape.circle),
            child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.summerModeActive,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFFB8860B))),
                const SizedBox(height: 2),
                Text(l10n.summerModeDesc,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A6D1F))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFF5C542),
          ),
        ],
      ),
    );
  }
}
