import '../../../../core/localization/app_localizations.dart';

/// Display classification for the Weather Impact grid. Two independent
/// pieces:
///  - [temperatureBand] is weather-only (same for every route right now,
///    same campus) — "how hot is it".
///  - [heatSafetyFor] is route-specific — "how hot does *this* route feel",
///    discounting the base temperature risk by how much shade the route
///    actually has. That's why a 38°C day can still be "Moderate / Shade
///    advised" for a well-shaded route rather than "High" outright.
/// Both are editorial heuristics, not a medical or meteorological
/// standard — reasonable enough for a UX hint, not a safety-critical
/// claim.
class WeatherRiskLabel {
  const WeatherRiskLabel({required this.label, required this.detail});

  final String label;
  final String detail;
}

WeatherRiskLabel temperatureBand(double temperatureC, AppLocalizations l10n) {
  if (temperatureC < 20) return WeatherRiskLabel(label: l10n.tempCold, detail: l10n.tempColdDetail);
  if (temperatureC < 27) return WeatherRiskLabel(label: l10n.tempMild, detail: l10n.tempMildDetail);
  if (temperatureC < 32) return WeatherRiskLabel(label: l10n.tempWarm, detail: l10n.tempWarmDetail);
  if (temperatureC < 39) return WeatherRiskLabel(label: l10n.tempHot, detail: l10n.tempHotDetail);
  return WeatherRiskLabel(label: l10n.tempVeryHot, detail: l10n.tempVeryHotDetail);
}

/// Real EPA/WHO UV index bands — the one classifier here that *is* a
/// recognized standard rather than an editorial choice.
WeatherRiskLabel uvBand(double uvIndex, AppLocalizations l10n) {
  if (uvIndex < 3) return WeatherRiskLabel(label: l10n.uvLow, detail: l10n.uvLowDetail);
  if (uvIndex < 6) return WeatherRiskLabel(label: l10n.uvModerate, detail: l10n.uvModerateDetail);
  if (uvIndex < 8) return WeatherRiskLabel(label: l10n.uvHigh, detail: l10n.uvHighDetail);
  if (uvIndex < 11) return WeatherRiskLabel(label: l10n.uvVeryHigh, detail: l10n.uvVeryHighDetail);
  return WeatherRiskLabel(label: l10n.uvExtreme, detail: l10n.uvExtremeDetail);
}

WeatherRiskLabel heatSafetyFor({
  required double temperatureC,
  required double shadePercent,
  required AppLocalizations l10n,
}) {
  final int baseRisk;
  if (temperatureC < 27) {
    baseRisk = 0;
  } else if (temperatureC < 32) {
    baseRisk = 1;
  } else if (temperatureC < 39) {
    baseRisk = 2;
  } else {
    baseRisk = 3;
  }

  final int shadeDiscount;
  if (shadePercent >= 80) {
    shadeDiscount = 2;
  } else if (shadePercent >= 55) {
    shadeDiscount = 1;
  } else {
    shadeDiscount = 0;
  }

  final effective = (baseRisk - shadeDiscount).clamp(0, 3);
  switch (effective) {
    case 0:
      return WeatherRiskLabel(label: l10n.heatSafeLow, detail: l10n.heatSafeLowDetail);
    case 1:
      return WeatherRiskLabel(label: l10n.heatSafeModerate, detail: l10n.heatSafeModerateDetail);
    case 2:
      return WeatherRiskLabel(label: l10n.heatSafeHigh, detail: l10n.heatSafeHighDetail);
    default:
      return WeatherRiskLabel(label: l10n.heatSafeExtreme, detail: l10n.heatSafeExtremeDetail);
  }
}

/// A practical, temperature-and-shade-driven heat-safety tip for Route
/// Details' advisory banner. Deliberately generic (peak-hours guidance
/// scaled to risk level) rather than naming a specific segment or
/// landmark — see the routing engine's tip generator for why this codebase
/// doesn't claim that kind of specificity without the data to back it.
///
/// Matched against [heatSafety.label] previously, which breaks once the
/// label itself is localized (comparing a possibly-Arabic string against
/// English literals) — matched against the effective risk level instead
/// via the detail-string identity is fragile too, so this now takes the
/// same temperature/shade inputs and recomputes the tier directly.
String heatSafetyTip({required double temperatureC, required double shadePercent, required AppLocalizations l10n}) {
  final baseRisk = temperatureC < 27
      ? 0
      : temperatureC < 32
          ? 1
          : temperatureC < 39
              ? 2
              : 3;
  final shadeDiscount = shadePercent >= 80 ? 2 : (shadePercent >= 55 ? 1 : 0);
  final effective = (baseRisk - shadeDiscount).clamp(0, 3);
  switch (effective) {
    case 0:
      return l10n.heatTipLow;
    case 1:
      return l10n.heatTipModerate;
    case 2:
      return l10n.heatTipHigh;
    default:
      return l10n.heatTipExtreme;
  }
}
