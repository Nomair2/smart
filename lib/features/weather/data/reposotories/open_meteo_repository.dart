import 'package:MasarKKU/features/weather/data/datasource/open_meteo_data_source.dart';
import 'package:MasarKKU/features/weather/domain/weather_repository.dart';

import '../../../home/domain/entities/weather_snapshot.dart';
import '../mappers/weather_mapper.dart';
import '../models/weather_model.dart';

class OpenMeteoRepository implements WeatherRepository {
  OpenMeteoRepository({
    required OpenMeteoDataSource dataSource,
    required double latitude,
    required double longitude,
    this.locationLabel = 'KKU Guraiger',
  }) : _dataSource = dataSource,
       _latitude = latitude,
       _longitude = longitude;

  final OpenMeteoDataSource _dataSource;

  final double _latitude;
  final double _longitude;

  final String locationLabel;

  @override
  Future<WeatherSnapshot> fetchCurrentWeather() async {
    final json = await _dataSource.fetchCurrentWeather(
      latitude: _latitude,
      longitude: _longitude,
    );

    final model = WeatherModel.fromJson(json);

    return WeatherMapper.toEntity(model, locationLabel: locationLabel);
  }
}
