import '../../../../core/domain/entities/season_mode.dart';
import '../../../../core/localization/app_localizations.dart';

/// Maps a 0-100 comfort score to a display band. Thresholds are an
/// editorial choice, not a scientific scale — tune here if "Good" should
/// kick in earlier or later.
class ComfortBand {
  const ComfortBand({required this.label, required this.shortLabel, required this.description});

  final String label;

  /// Short caption for inside the circular gauge (e.g. "GOOD") — written
  /// directly per locale rather than derived from [label] by splitting
  /// words (that trick doesn't translate: Arabic word order differs).
  final String shortLabel;

  final String description;
}

ComfortBand comfortBandFor({
  required double comfortScore,
  required SeasonMode seasonMode,
  required double shadePercent,
  required AppLocalizations l10n,
}) {
  final seasonWord = switch (seasonMode) {
    SeasonMode.summer => l10n.seasonWordSummer,
    SeasonMode.winter => l10n.seasonWordWinter,
    SeasonMode.auto => l10n.seasonWordCurrent,
  };

  final String label;
  final String shortLabel;
  if (comfortScore >= 85) {
    label = l10n.comfortExcellent;
    shortLabel = l10n.comfortExcellentShort;
  } else if (comfortScore >= 70) {
    label = l10n.comfortGood;
    shortLabel = l10n.comfortGoodShort;
  } else if (comfortScore >= 50) {
    label = l10n.comfortFair;
    shortLabel = l10n.comfortFairShort;
  } else {
    label = l10n.comfortLow;
    shortLabel = l10n.comfortLowShort;
  }

  final String description;
  if (shadePercent >= 70) {
    description = l10n.comfortDescGreatShade(seasonWord);
  } else if (shadePercent >= 45) {
    description = l10n.comfortDescSolidShade;
  } else {
    description = l10n.comfortDescLimitedShade;
  }

  return ComfortBand(label: label, shortLabel: shortLabel, description: description);
}
