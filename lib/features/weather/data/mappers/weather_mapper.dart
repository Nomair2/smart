import '../../../home/domain/entities/weather_snapshot.dart';
import '../models/weather_model.dart';

class WeatherMapper {
  static WeatherSnapshot toEntity(
    WeatherModel model, {
    required String locationLabel,
  }) {
    return WeatherSnapshot(
      locationLabel: locationLabel,
      temperatureC: model.temperatureC,
      feelsLikeC: model.feelsLikeC,
      condition: _conditionFromCode(model.weatherCode),
      windSpeedKph: model.windSpeedKph,
      uvIndex: model.uvIndex,
      isHeatAlert: model.temperatureC >= 38,
      fetchedAt: model.fetchedAt,
    );
  }

  static String _conditionFromCode(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';

      case 1:
        return 'Mainly clear';

      case 2:
        return 'Partly cloudy';

      case 3:
        return 'Overcast';

      case 45:
      case 48:
        return 'Fog';

      case 51:
      case 53:
      case 55:
        return 'Drizzle';

      case 61:
      case 63:
      case 65:
        return 'Rain';

      case 71:
      case 73:
      case 75:
        return 'Snow';

      case 80:
      case 81:
      case 82:
        return 'Rain showers';

      case 95:
        return 'Thunderstorm';

      case 96:
      case 99:
        return 'Thunderstorm with hail';

      default:
        return 'Unknown';
    }
  }
}
