import '../../../../core/domain/entities/season_mode.dart';

/// Maps a 0-100 comfort score to a display band. Thresholds are an
/// editorial choice, not a scientific scale — tune here if "Good" should
/// kick in earlier or later.
class ComfortBand {
  const ComfortBand({required this.label, required this.shortLabel, required this.description});

  final String label;

  /// Short caption for inside the circular gauge (e.g. "GOOD") — derived
  /// from the same threshold as [label], not a separate guess.
  final String shortLabel;

  final String description;
}

ComfortBand comfortBandFor({
  required double comfortScore,
  required SeasonMode seasonMode,
  required double shadePercent,
}) {
  final seasonWord = switch (seasonMode) {
    SeasonMode.summer => 'summer',
    SeasonMode.winter => 'winter',
    SeasonMode.auto => 'current',
  };

  final String label;
  if (comfortScore >= 85) {
    label = 'Excellent Comfort Level';
  } else if (comfortScore >= 70) {
    label = 'Good Comfort Level';
  } else if (comfortScore >= 50) {
    label = 'Fair Comfort Level';
  } else {
    label = 'Low Comfort Level';
  }
  final shortLabel = label.split(' ').first.toUpperCase();

  final String description;
  if (shadePercent >= 70) {
    description = 'This route offers excellent shade coverage with minimal sun '
        'exposure — ideal for $seasonWord navigation at KKU.';
  } else if (shadePercent >= 45) {
    description = 'This route offers solid shade coverage along most of the walk.';
  } else {
    description = 'This route has limited shade coverage — carry water and sun protection.';
  }

  return ComfortBand(label: label, shortLabel: shortLabel, description: description);
}
