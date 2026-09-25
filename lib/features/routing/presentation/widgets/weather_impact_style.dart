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

WeatherRiskLabel temperatureBand(double temperatureC) {
  if (temperatureC < 20) return const WeatherRiskLabel(label: 'Cold', detail: 'Low risk');
  if (temperatureC < 27) return const WeatherRiskLabel(label: 'Mild', detail: 'Low risk');
  if (temperatureC < 32) return const WeatherRiskLabel(label: 'Warm', detail: 'Moderate risk');
  if (temperatureC < 39) return const WeatherRiskLabel(label: 'Hot', detail: 'High risk');
  return const WeatherRiskLabel(label: 'Very Hot', detail: 'Extreme risk');
}

/// Real EPA/WHO UV index bands — the one classifier here that *is* a
/// recognized standard rather than an editorial choice.
WeatherRiskLabel uvBand(double uvIndex) {
  if (uvIndex < 3) return const WeatherRiskLabel(label: 'Low', detail: 'Minimal protection needed');
  if (uvIndex < 6) return const WeatherRiskLabel(label: 'Moderate', detail: 'Wear sunscreen');
  if (uvIndex < 8) return const WeatherRiskLabel(label: 'High', detail: 'Seek shade at midday');
  if (uvIndex < 11) return const WeatherRiskLabel(label: 'Very High', detail: 'Extra protection needed');
  return const WeatherRiskLabel(label: 'Extreme', detail: 'Avoid sun exposure');
}

WeatherRiskLabel heatSafetyFor({required double temperatureC, required double shadePercent}) {  final int baseRisk;
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
      return const WeatherRiskLabel(label: 'Low', detail: 'Comfortable conditions');
    case 1:
      return const WeatherRiskLabel(label: 'Moderate', detail: 'Shade advised');
    case 2:
      return const WeatherRiskLabel(label: 'High', detail: 'Seek shade frequently');
    default:
      return const WeatherRiskLabel(label: 'Extreme', detail: 'Avoid prolonged exposure');
  }
}

/// A practical, temperature-and-shade-driven heat-safety tip for Route
/// Details' advisory banner. Deliberately generic (peak-hours guidance
/// scaled to risk level) rather than naming a specific segment or
/// landmark — see the routing engine's tip generator for why this codebase
/// doesn't claim that kind of specificity without the data to back it.
String heatSafetyTip({required WeatherRiskLabel heatSafety}) {
  switch (heatSafety.label) {
    case 'Low':
      return 'Conditions are comfortable for walking — no special precautions needed.';
    case 'Moderate':
      return 'Carry water and avoid prolonged exposure during peak hours (12PM\u20133PM).';
    case 'High':
      return 'Carry water, wear sun protection, and take shaded breaks during peak hours (12PM\u20133PM).';
    default:
      return 'Avoid non-essential outdoor walking during peak hours (12PM\u20133PM) if possible.';
  }
}
