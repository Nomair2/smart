import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/geo_coordinate.dart';
import '../../../../core/domain/entities/season_mode.dart';
import '../../../home/domain/entities/weather_snapshot.dart';
import 'campus_node.dart';
import 'guidance_instruction.dart';
import 'route_optimization_goal.dart';

/// One of the "Shortest Path" / "Balanced Route" rows shown alongside the
/// primary result — a cheap summary, not a second full [RouteResult] (no
/// point computing guidance/tips for a route the user didn't pick).
class AlternativeRouteSummary extends Equatable {
  const AlternativeRouteSummary({
    required this.goal,
    required this.distanceMeters,
    required this.estimatedTime,
    required this.shadePercent,
  });

  final RouteOptimizationGoal goal;
  final double distanceMeters;
  final Duration estimatedTime;
  final double shadePercent;

  @override
  List<Object?> get props => [goal, distanceMeters, estimatedTime, shadePercent];
}

/// The full answer from [RoutingEngine.findRoute] — everything Best Route
/// Found, Route Details, and Route Guide need, computed once so those
/// three screens never have to re-run the search or re-fetch weather.
class RouteResult extends Equatable {
  const RouteResult({
    required this.origin,
    required this.destination,
    required this.nodePath,
    required this.geometry,
    required this.distanceMeters,
    required this.estimatedTime,
    required this.comfortScore,
    required this.shadePercent,
    required this.sunPercent,
    required this.naturalBreezePercent,
    required this.pavedAccessiblePercent,
    required this.windLabel,
    required this.weather,
    required this.tip,
    required this.seasonMode,
    required this.goal,
    required this.alternatives,
    required this.instructions,
  });

  final CampusNode origin;
  final CampusNode destination;

  /// Every graph node on the path, intersections included — useful for
  /// debugging/admin views, not for display (use [geometry] for that).
  final List<CampusNode> nodePath;

  /// The full walkable polyline, turning points included, boundary points
  /// between segments de-duplicated.
  final List<GeoCoordinate> geometry;

  final double distanceMeters;
  final Duration estimatedTime;

  /// 0-100. Not a copy of [shadePercent] — see [RoutingEngine] for how it's
  /// blended with "how much better is this than the shortest alternative".
  final double comfortScore;

  final double shadePercent;
  final double sunPercent;

  /// 0-100, a heuristic mapping from live wind speed — not a real airflow
  /// measurement (no per-segment wind-exposure data exists).
  final double naturalBreezePercent;

  /// 0-100, distance-weighted share of segments used with
  /// `PathSegment.isPaved == true` — same weighting pattern as
  /// [shadePercent], so one long unpaved stretch isn't hidden by several
  /// short paved ones.
  final double pavedAccessiblePercent;

  /// Calm / Fair / Breezy / Strong — derived from live wind speed.
  final String windLabel;

  /// The exact weather reading this route was optimized against — stored
  /// here rather than re-fetched by Route Details, so the temperature that
  /// screen shows can never disagree with the one that actually drove the
  /// summer/winter cost decision.
  final WeatherSnapshot weather;

  final String tip;
  final SeasonMode seasonMode;
  final RouteOptimizationGoal goal;
  final List<AlternativeRouteSummary> alternatives;
  final List<GuidanceInstruction> instructions;

  @override
  List<Object?> get props => [
        origin,
        destination,
        nodePath,
        geometry,
        distanceMeters,
        estimatedTime,
        comfortScore,
        shadePercent,
        sunPercent,
        naturalBreezePercent,
        pavedAccessiblePercent,
        windLabel,
        weather,
        tip,
        seasonMode,
        goal,
        alternatives,
        instructions,
      ];
}
