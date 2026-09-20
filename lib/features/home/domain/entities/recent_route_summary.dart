import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/season_mode.dart';

/// A row in the home screen's "Recent Routes" list — a lightweight view of
/// a `route_requests` document, not the full route/geometry.
class RecentRouteSummary extends Equatable {
  const RecentRouteSummary({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.walkMinutes,
    required this.requestedAt,
    required this.seasonMode,
  });

  final String id;
  final String originName;
  final String destinationName;
  final int walkMinutes;
  final DateTime requestedAt;
  final SeasonMode seasonMode;

  @override
  List<Object?> get props =>
      [id, originName, destinationName, walkMinutes, requestedAt, seasonMode];
}
