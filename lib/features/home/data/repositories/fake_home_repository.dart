import '../../../../core/domain/entities/season_mode.dart';
import '../../domain/entities/recent_route_summary.dart';
import '../../domain/entities/weather_snapshot.dart';
import '../../domain/repositories/home_repository.dart';

/// Stub data matching the report's Abha climate assumptions, so the home
/// screen is fully demoable before the weather API (C1) and routing engine
/// (C4) exist. Replace with real implementations when those features land.
class FakeHomeRepository implements HomeRepository {
  @override
  Future<WeatherSnapshot> fetchCurrentWeather() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return WeatherSnapshot(
      locationLabel: 'Abha, KKU Campus',
      temperatureC: 38,
      feelsLikeC: 42,
      condition: 'Sunny & Hot',
      windSpeedKph: 12,
      isHeatAlert: true,
      fetchedAt: DateTime.now(),
    );
  }

  @override
  Future<List<RecentRouteSummary>> fetchRecentRoutes({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      RecentRouteSummary(
        id: '1',
        originName: 'Gate 1',
        destinationName: 'CS Building',
        walkMinutes: 8,
        requestedAt: now.subtract(const Duration(hours: 2)),
        seasonMode: SeasonMode.summer,
      ),
      RecentRouteSummary(
        id: '2',
        originName: 'Library',
        destinationName: 'Gate 3',
        walkMinutes: 5,
        requestedAt: now.subtract(const Duration(days: 1)),
        seasonMode: SeasonMode.winter,
      ),
    ].take(limit).toList();
  }
}
