import 'package:MasarKKU/features/weather/domain/weather_repository.dart';

import '../../../home/domain/entities/weather_snapshot.dart';

class FakeWeatherRepository implements WeatherRepository {
  @override
  Future<WeatherSnapshot> fetchCurrentWeather() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return WeatherSnapshot(
      locationLabel: 'KKU Guraiger',
      temperatureC: 38,
      feelsLikeC: 39,
      condition: 'Clear sky',
      windSpeedKph: 12,
      uvIndex: 9,
      isHeatAlert: true,
      fetchedAt: DateTime.now(),
    );
  }
}
