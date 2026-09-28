import 'package:MasarKKU/features/home/domain/entities/weather_snapshot.dart';

abstract class WeatherRepository {
  Future<WeatherSnapshot> fetchCurrentWeather();
}
