import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/geo_coordinate.dart';

enum PathSegmentStatus { open, closed, maintenance }

/// Matches report Table 8 (`path_segments`), extended with `geometry` — the
/// traced sequence of points between [fromNodeId] and [toNodeId], including
/// any turning points along the way. Distance is derived from this list
/// (sum of consecutive Haversine distances) rather than stored separately,
/// so it can never drift out of sync with the actual traced path.
class PathSegment extends Equatable {
  PathSegment({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.geometry,
    required this.shadeScore,
    this.status = PathSegmentStatus.open,
  }) : assert(geometry.length >= 2, 'A segment needs at least its two endpoints'),
       assert(shadeScore >= 0 && shadeScore <= 1, 'shadeScore is a 0-1 fraction');

  final String id;
  final String fromNodeId;
  final String toNodeId;

  /// Ordered from [fromNodeId]'s location to [toNodeId]'s location.
  final List<GeoCoordinate> geometry;

  /// 0 = fully exposed, 1 = fully shaded, for this whole segment. One value
  /// per segment rather than per point — see the design discussion: campus
  /// segments between two intersections are short enough that shade
  /// doesn't meaningfully vary within one without real field-survey data.
  final double shadeScore;

  final PathSegmentStatus status;

  late final double distanceMeters = _computeDistance();

  double _computeDistance() {
    var total = 0.0;
    for (var i = 1; i < geometry.length; i++) {
      total += geometry[i - 1].distanceInMetersTo(geometry[i]);
    }
    return total;
  }

  @override
  List<Object?> get props => [id, fromNodeId, toNodeId, geometry, shadeScore, status];
}
