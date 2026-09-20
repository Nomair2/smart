import 'package:equatable/equatable.dart';

/// A single weather reading for the campus, shaped for display — not the
/// raw provider response. Matches the report's `weather_snapshots` table
/// conceptually (temperature, condition, wind) plus the derived bits the
/// home screen needs (heat alert, a human-readable condition line).
class WeatherSnapshot extends Equatable {
  const WeatherSnapshot({
    required this.locationLabel,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.condition,
    required this.windSpeedKph,
    required this.isHeatAlert,
    required this.fetchedAt,
  });

  final String locationLabel;
  final double temperatureC;
  final double feelsLikeC;
  final String condition;
  final double windSpeedKph;
  final bool isHeatAlert;
  final DateTime fetchedAt;

  @override
  List<Object?> get props =>
      [locationLabel, temperatureC, feelsLikeC, condition, windSpeedKph, isHeatAlert, fetchedAt];
}
