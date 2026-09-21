import '../../../core/domain/entities/geo_coordinate.dart';
import '../../../core/domain/entities/season_mode.dart';
import 'entities/campus_node.dart';
import 'entities/guidance_instruction.dart';
import 'entities/path_segment.dart';
import 'entities/route_optimization_goal.dart';
import 'entities/route_request.dart';
import 'entities/route_result.dart';

/// Multi-Constraint A* over the campus outdoor graph (report requirement
/// C4), pure Dart — no Flutter or Firebase imports, so it's independently
/// testable and has no dependency on how the graph was loaded.
///
/// Cost model: for a segment, define an exposure penalty from its
/// `shadeScore` — in summer an *unshaded* segment costs more
/// (`penalty = 1 - shadeScore`); in winter a *shaded* segment costs more
/// (`penalty = shadeScore`, inverted). Then per goal:
///   shortest -> cost = distance                       (comfort ignored)
///   comfort  -> cost = distance * (1 + kComfort * penalty)
///   balanced -> cost = distance * (1 + kComfort/2 * penalty)
///
/// Since the multiplier is never below 1, `cost >= distance` always, which
/// is what keeps the straight-line (Haversine) heuristic admissible for
/// every goal — one heuristic function correctly serves all three, no need
/// for three different search configurations.
class RoutingEngine {
  RoutingEngine({this.comfortWeight = 1.5});

  /// How aggressively "Comfort" detours for shade/sun. "Balanced" always
  /// uses half of this. Tune here if routes feel over- or under-eager to
  /// detour.
  final double comfortWeight;

  static const _walkingSpeedMetersPerSecond = 1.3; // ~4.7 km/h campus pace

  /// Returns `null` if either endpoint doesn't exist in [nodes] or no
  /// walkable path connects them (e.g. every connecting segment is closed).
  RouteResult? findRoute({
    required List<CampusNode> nodes,
    required List<PathSegment> segments,
    required RouteRequest request,
    required double currentTemperatureC,
    required double windSpeedKph,
  }) {
    final nodesById = {for (final n in nodes) n.id: n};
    final origin = nodesById[request.originNodeId];
    final destination = nodesById[request.destinationNodeId];
    if (origin == null || destination == null) return null;

    final adjacency = _buildAdjacency(segments);
    final season = _resolveSeason(request.seasonMode, currentTemperatureC);

    final primary = _search(
      nodesById: nodesById,
      adjacency: adjacency,
      startId: origin.id,
      goalId: destination.id,
      edgeCost: (s) => _costFor(s, request.goal, season),
    );
    if (primary == null) return null;

    final alternatives = <AlternativeRouteSummary>[];
    for (final goal in RouteOptimizationGoal.values) {
      if (goal == request.goal) continue;
      final result = _search(
        nodesById: nodesById,
        adjacency: adjacency,
        startId: origin.id,
        goalId: destination.id,
        edgeCost: (s) => _costFor(s, goal, season),
      );
      if (result != null) {
        alternatives.add(AlternativeRouteSummary(
          goal: goal,
          distanceMeters: result.totalDistance,
          estimatedTime: _walkDuration(result.totalDistance),
          shadePercent: _shadePercent(result.edges),
        ));
      }
    }

    final geometry = _flattenGeometry(primary.edges);
    final shadePercent = _shadePercent(primary.edges);
    AlternativeRouteSummary? shortestAlt;
    for (final alt in alternatives) {
      if (alt.goal == RouteOptimizationGoal.shortest) {
        shortestAlt = alt;
        break;
      }
    }

    return RouteResult(
      origin: origin,
      destination: destination,
      nodePath: primary.nodeIds.map((id) => nodesById[id]!).toList(),
      geometry: geometry,
      distanceMeters: primary.totalDistance,
      estimatedTime: _walkDuration(primary.totalDistance),
      comfortScore: _comfortScore(shadePercent, shortestAlt),
      shadePercent: shadePercent,
      sunPercent: 100 - shadePercent,
      windLabel: _windLabel(windSpeedKph),
      tip: _tipFor(request.goal, season),
      seasonMode: request.seasonMode,
      goal: request.goal,
      alternatives: alternatives,
      instructions: _generateGuidance(geometry, origin, destination),
    );
  }

  // ---------------------------------------------------------------------
  // Cost model
  // ---------------------------------------------------------------------

  double _costFor(PathSegment segment, RouteOptimizationGoal goal, _ResolvedSeason season) {
    final distance = segment.distanceMeters;
    if (goal == RouteOptimizationGoal.shortest) return distance;

    final penalty =
        season == _ResolvedSeason.summer ? (1 - segment.shadeScore) : segment.shadeScore;
    final k = goal == RouteOptimizationGoal.comfort ? comfortWeight : comfortWeight / 2;
    return distance * (1 + k * penalty);
  }

  _ResolvedSeason _resolveSeason(SeasonMode mode, double temperatureC) {
    switch (mode) {
      case SeasonMode.summer:
        return _ResolvedSeason.summer;
      case SeasonMode.winter:
        return _ResolvedSeason.winter;
      case SeasonMode.auto:
        return temperatureC >= 28 ? _ResolvedSeason.summer : _ResolvedSeason.winter;
    }
  }

  // ---------------------------------------------------------------------
  // A* search
  // ---------------------------------------------------------------------

  Map<String, List<_DirectedEdge>> _buildAdjacency(List<PathSegment> segments) {
    final adjacency = <String, List<_DirectedEdge>>{};
    for (final segment in segments) {
      adjacency
          .putIfAbsent(segment.fromNodeId, () => [])
          .add(_DirectedEdge(fromNodeId: segment.fromNodeId, toNodeId: segment.toNodeId, segment: segment, reversed: false));
      adjacency
          .putIfAbsent(segment.toNodeId, () => [])
          .add(_DirectedEdge(fromNodeId: segment.toNodeId, toNodeId: segment.fromNodeId, segment: segment, reversed: true));
    }
    return adjacency;
  }

  /// Textbook A* with a linear scan for the lowest f-score open node —
  /// deliberately not a binary heap. A campus graph is dozens of nodes, not
  /// thousands; an O(n^2) scan is instant at this scale and keeps this file
  /// dependency-free rather than pulling in `package:collection` for a
  /// priority queue this graph will never be big enough to need.
  _SearchResult? _search({
    required Map<String, CampusNode> nodesById,
    required Map<String, List<_DirectedEdge>> adjacency,
    required String startId,
    required String goalId,
    required double Function(PathSegment) edgeCost,
  }) {
    if (startId == goalId) return null;
    final goalNode = nodesById[goalId];
    if (goalNode == null || !nodesById.containsKey(startId)) return null;

    final gScore = <String, double>{startId: 0};
    final cameFromEdge = <String, _DirectedEdge>{};
    final open = <String>{startId};
    final closed = <String>{};

    while (open.isNotEmpty) {
      var current = open.first;
      var bestF = double.infinity;
      for (final id in open) {
        final f = (gScore[id] ?? double.infinity) + nodesById[id]!.location.distanceInMetersTo(goalNode.location);
        if (f < bestF) {
          bestF = f;
          current = id;
        }
      }

      if (current == goalId) {
        return _reconstructPath(cameFromEdge, startId, goalId, gScore[goalId]!);
      }

      open.remove(current);
      closed.add(current);

      for (final edge in adjacency[current] ?? const <_DirectedEdge>[]) {
        if (closed.contains(edge.toNodeId)) continue;
        if (edge.segment.status != PathSegmentStatus.open) continue;

        final tentativeG = gScore[current]! + edgeCost(edge.segment);
        if (tentativeG < (gScore[edge.toNodeId] ?? double.infinity)) {
          cameFromEdge[edge.toNodeId] = edge;
          gScore[edge.toNodeId] = tentativeG;
          open.add(edge.toNodeId);
        }
      }
    }
    return null;
  }

  _SearchResult _reconstructPath(
    Map<String, _DirectedEdge> cameFromEdge,
    String startId,
    String goalId,
    double totalCost,
  ) {
    final edges = <_DirectedEdge>[];
    final nodeIds = <String>[goalId];
    var cursor = goalId;
    while (cursor != startId) {
      final edge = cameFromEdge[cursor]!;
      edges.add(edge);
      cursor = edge.fromNodeId;
      nodeIds.add(cursor);
    }
    return _SearchResult(
      nodeIds: nodeIds.reversed.toList(),
      edges: edges.reversed.toList(),
      totalDistance: edges.fold(0.0, (sum, e) => sum + e.segment.distanceMeters),
      totalCost: totalCost,
    );
  }

  // ---------------------------------------------------------------------
  // Result shaping
  // ---------------------------------------------------------------------

  List<GeoCoordinate> _flattenGeometry(List<_DirectedEdge> edges) {
    final points = <GeoCoordinate>[];
    for (final edge in edges) {
      final segmentGeometry = edge.orientedGeometry;
      // Consecutive segments share their boundary point (the node between
      // them) — drop the duplicate rather than double-counting it.
      points.addAll(points.isEmpty ? segmentGeometry : segmentGeometry.skip(1));
    }
    return points;
  }

  /// Distance-weighted average shade across the segments used, so one long
  /// exposed segment isn't diluted by several short shaded ones (or vice
  /// versa).
  double _shadePercent(List<_DirectedEdge> edges) {
    if (edges.isEmpty) return 0;
    var totalDistance = 0.0;
    var weightedShade = 0.0;
    for (final edge in edges) {
      totalDistance += edge.segment.distanceMeters;
      weightedShade += edge.segment.distanceMeters * edge.segment.shadeScore;
    }
    if (totalDistance == 0) return 0;
    return (weightedShade / totalDistance) * 100;
  }

  /// Shade percent plus a small bonus for how much better this route is
  /// than the shortest alternative — this is why Comfort (e.g. 78%) isn't
  /// just a copy of Shade (e.g. 72%) in the UI.
  double _comfortScore(double shadePercent, AlternativeRouteSummary? shortestAlt) {
    if (shortestAlt == null) return shadePercent.clamp(0, 100);
    final shadeGain = (shadePercent - shortestAlt.shadePercent).clamp(0, 100);
    return (shadePercent + shadeGain * 0.15).clamp(0, 100);
  }

  Duration _walkDuration(double distanceMeters) {
    final seconds = distanceMeters / _walkingSpeedMetersPerSecond;
    return Duration(seconds: seconds.round());
  }

  String _windLabel(double windSpeedKph) {
    if (windSpeedKph < 8) return 'Calm';
    if (windSpeedKph < 20) return 'Fair';
    if (windSpeedKph < 35) return 'Breezy';
    return 'Strong';
  }

  String _tipFor(RouteOptimizationGoal goal, _ResolvedSeason season) {
    if (goal == RouteOptimizationGoal.shortest) {
      return "This is the shortest path available — comfort wasn't a factor.";
    }
    final feature = season == _ResolvedSeason.summer ? 'shade coverage' : 'sun exposure';
    final condition = season == _ResolvedSeason.summer ? 'the heat' : 'the cold';
    return 'This route maximizes $feature to keep you comfortable in $condition.';
  }

  // ---------------------------------------------------------------------
  // Guidance generation (requirement A8/C5)
  // ---------------------------------------------------------------------

  /// Walks the route's *flattened point-level* geometry — not just its
  /// graph nodes — so a bend in the middle of a segment (a turning point,
  /// never a graph node; see the design discussion) still produces a real
  /// "turn left/right" instruction.
  List<GuidanceInstruction> _generateGuidance(
    List<GeoCoordinate> geometry,
    CampusNode origin,
    CampusNode destination,
  ) {
    if (geometry.length < 2) return const [];

    final instructions = <GuidanceInstruction>[
      GuidanceInstruction(
        stepOrder: 0,
        action: ManeuverType.start,
        text: 'Head out from ${origin.name ?? 'your starting point'} toward ${destination.name ?? 'your destination'}',
        location: geometry.first,
        legDistanceMeters: 0,
      ),
    ];

    var legDistance = 0.0;
    for (var i = 1; i < geometry.length - 1; i++) {
      final prev = geometry[i - 1];
      final curr = geometry[i];
      final next = geometry[i + 1];
      legDistance += prev.distanceInMetersTo(curr);

      final bearingIn = prev.bearingDegreesTo(curr);
      final bearingOut = curr.bearingDegreesTo(next);
      var delta = bearingOut - bearingIn;
      delta = ((delta + 180) % 360) - 180; // normalize to [-180, 180]

      if (delta.abs() >= 20) {
        final turningRight = delta > 0;
        instructions.add(GuidanceInstruction(
          stepOrder: instructions.length,
          action: turningRight ? ManeuverType.right : ManeuverType.left,
          text: '${turningRight ? 'Turn right' : 'Turn left'} in ${legDistance.round()} m',
          location: curr,
          legDistanceMeters: legDistance,
        ));
        legDistance = 0;
      }
    }

    legDistance += geometry[geometry.length - 2].distanceInMetersTo(geometry.last);
    instructions.add(GuidanceInstruction(
      stepOrder: instructions.length,
      action: ManeuverType.arrive,
      text: 'Arrive at ${destination.name ?? 'your destination'}',
      location: geometry.last,
      legDistanceMeters: legDistance,
    ));

    return instructions;
  }
}

enum _ResolvedSeason { summer, winter }

class _DirectedEdge {
  const _DirectedEdge({
    required this.fromNodeId,
    required this.toNodeId,
    required this.segment,
    required this.reversed,
  });

  final String fromNodeId;
  final String toNodeId;
  final PathSegment segment;
  final bool reversed;

  List<GeoCoordinate> get orientedGeometry =>
      reversed ? segment.geometry.reversed.toList() : segment.geometry;
}

class _SearchResult {
  const _SearchResult({
    required this.nodeIds,
    required this.edges,
    required this.totalDistance,
    required this.totalCost,
  });

  final List<String> nodeIds;
  final List<_DirectedEdge> edges;
  final double totalDistance;
  final double totalCost;
}
