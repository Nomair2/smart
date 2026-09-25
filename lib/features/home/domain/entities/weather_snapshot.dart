import 'package:equatable/equatable.dart';

/// A single weather reading for the campus, shaped for display — not the
/// raw provider response.
class WeatherSnapshot extends Equatable {
  const WeatherSnapshot({
    required this.locationLabel,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.condition,
    required this.windSpeedKph,
    required this.isHeatAlert,
    required this.fetchedAt,
    this.uvIndex,
  });

  final String locationLabel;
  final double temperatureC;
  final double feelsLikeC;
  final String condition;
  final double windSpeedKph;
  final bool isHeatAlert;

  /// UV index can be unavailable depending on the weather provider.
  final double? uvIndex;

  final DateTime fetchedAt;

  @override
  List<Object?> get props => [
    locationLabel,
    temperatureC,
    feelsLikeC,
    condition,
    windSpeedKph,
    isHeatAlert,
    uvIndex,
    fetchedAt,
  ];
}
