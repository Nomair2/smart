import 'package:flutter/material.dart';

import '../../domain/entities/season_mode.dart';

/// Shared bottom sheet for picking a [SeasonMode] — used by both the home
/// screen's "Season Mode" quick action and the profile screen's "Season
/// Preferences" tile, so there's one place that defines what the picker
/// looks like.
void showSeasonModePicker(
  BuildContext context, {
  required SeasonMode current,
  required ValueChanged<SeasonMode> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: SeasonMode.values.map((mode) {
            return RadioListTile<SeasonMode>(
              value: mode,
              groupValue: current,
              title: Text('${mode.label} Mode'),
              activeColor: const Color(0xFF1E5B3D),
              onChanged: (value) {
                if (value != null) onSelected(value);
                Navigator.of(sheetContext).pop();
              },
            );
          }).toList(),
        ),
      );
    },
  );
}
