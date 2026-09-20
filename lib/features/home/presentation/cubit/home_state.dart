import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/recent_route_summary.dart';
import '../../domain/entities/weather_snapshot.dart';

enum HomeStatus { loading, loaded, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.profile,
    this.weather,
    this.recentRoutes = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final UserProfile? profile;
  final WeatherSnapshot? weather;
  final List<RecentRouteSummary> recentRoutes;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    UserProfile? profile,
    WeatherSnapshot? weather,
    List<RecentRouteSummary>? recentRoutes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      weather: weather ?? this.weather,
      recentRoutes: recentRoutes ?? this.recentRoutes,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, weather, recentRoutes, errorMessage];
}
