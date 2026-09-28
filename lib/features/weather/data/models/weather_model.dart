class WeatherModel {
  const WeatherModel({
    required this.temperatureC,
    required this.feelsLikeC,
    required this.windSpeedKph,
    required this.uvIndex,
    required this.weatherCode,
    required this.fetchedAt,
  });

  final double temperatureC;
  final double feelsLikeC;
  final double windSpeedKph;
  final double? uvIndex;
  final int weatherCode;
  final DateTime fetchedAt;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;

    return WeatherModel(
      temperatureC: (current['temperature_2m'] as num).toDouble(),
      feelsLikeC: (current['apparent_temperature'] as num).toDouble(),
      windSpeedKph: (current['wind_speed_10m'] as num).toDouble(),
      uvIndex: (current['uv_index'] as num?)?.toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      fetchedAt: DateTime.now(),
    );
  }
}
