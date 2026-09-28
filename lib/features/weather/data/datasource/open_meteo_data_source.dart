import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenMeteoDataSource {
  OpenMeteoDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,apparent_temperature,weather_code,wind_speed_10m,uv_index',
      'timezone': 'auto',
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Open-Meteo request failed: ${response.statusCode}');
    }
    print(response.body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
