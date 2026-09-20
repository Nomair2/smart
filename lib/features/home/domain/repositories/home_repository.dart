import '../entities/recent_route_summary.dart';
import '../entities/weather_snapshot.dart';

/// Everything the home screen needs beyond the user's own profile
/// (ProfileRepository already covers name/season preference).
///
/// Both methods are still backed by stubs ([lib/features/home/data
/// /repositories/fake_home_repository.dart]) — weather needs the C1
/// OpenWeatherMap integration and recent routes needs the routing engine
/// (C4/C7) writing to `route_requests` before either can be real. Swap the
/// provider in main.dart for a real implementation once those exist; no
/// other file in this feature needs to change.
abstract class HomeRepository {
  Future<WeatherSnapshot> fetchCurrentWeather();

  Future<List<RecentRouteSummary>> fetchRecentRoutes({int limit = 5});
}
