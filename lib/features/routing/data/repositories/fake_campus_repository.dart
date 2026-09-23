import '../../../../core/domain/entities/geo_coordinate.dart';
import '../../domain/entities/campus_node.dart';
import '../../domain/entities/path_segment.dart';
import '../../domain/repositories/campus_repository.dart';

/// Illustrative campus graph, not a survey — 12 destinations (matching the
/// Select Route dropdown) connected through 6 real intersection nodes with
/// hand-traced, multi-point path geometry. This is deliberately *not* just
/// destinations wired directly to each other: without intersections, every
/// origin/destination pair would have exactly one physical route, and
/// Comfort/Shortest/Balanced would always compute the same path.
///
/// Coordinates are anchored near Abha (~18.2465, 42.5117) for realistic
/// map testing later, with small hand-placed offsets — not real KKU
/// surveyed positions. Swapping this for `FirestoreCampusRepository`, once
/// B3/B4 (admin endpoint/path management) exist to populate real data, is a
/// one-line change in main.dart.
class FakeCampusRepository implements CampusRepository {
  static const _baseLat = 18.2465;
  static const _baseLng = 42.5117;

  static GeoCoordinate _pt(double dLat, double dLng) =>
      GeoCoordinate(latitude: _baseLat + dLat, longitude: _baseLng + dLng);

  // ---- Destinations (report Table 7, node_type gate/building_external) ----
  static final mainGate = CampusNode(
      id: 'gate_1', code: 'G1', name: 'Main Gate (Gate 1)', type: CampusNodeType.gate, location: _pt(-0.0026, -0.0002));
  static final gate2East = CampusNode(
      id: 'gate_2', code: 'G2', name: 'Gate 2 — East', type: CampusNodeType.gate, location: _pt(0.0002, 0.0026));
  static final gate3South = CampusNode(
      id: 'gate_3', code: 'G3', name: 'Gate 3 — South', type: CampusNodeType.gate, location: _pt(-0.0024, -0.0016));
  static final gate4West = CampusNode(
      id: 'gate_4', code: 'G4', name: 'Gate 4 — West', type: CampusNodeType.gate, location: _pt(-0.0004, -0.0026));
  static final csItBuilding = CampusNode(
      id: 'bldg_cs_it', name: 'CS & IT Building', type: CampusNodeType.buildingExternal, location: _pt(0.0012, 0.0016));
  static final engineeringBuilding = CampusNode(
      id: 'bldg_eng', name: 'Engineering Building', type: CampusNodeType.buildingExternal, location: _pt(0.0020, 0.0008));
  static final library = CampusNode(
      id: 'bldg_library', name: 'Library', type: CampusNodeType.buildingExternal, location: _pt(0.0004, 0.0008));
  static final adminBuilding = CampusNode(
      id: 'bldg_admin', name: 'Admin Building', type: CampusNodeType.buildingExternal, location: _pt(-0.0008, 0.0006));
  static final medicalCollege = CampusNode(
      id: 'bldg_medical', name: 'Medical College', type: CampusNodeType.buildingExternal, location: _pt(0.0022, -0.0008));
  static final mosque = CampusNode(
      id: 'poi_mosque', name: 'Mosque', type: CampusNodeType.buildingExternal, location: _pt(-0.0002, 0.0004));
  static final studentCenter = CampusNode(
      id: 'bldg_student_center', name: 'Student Center', type: CampusNodeType.buildingExternal, location: _pt(0.0008, 0.0002));
  static final cafeteria = CampusNode(
      id: 'bldg_cafeteria', name: 'Cafeteria', type: CampusNodeType.buildingExternal, location: _pt(0.0014, 0.0002));

  // ---- Intersections — real decision points, never shown in the UI ----
  static final _i1 = CampusNode(id: 'x_1', type: CampusNodeType.intersection, location: _pt(-0.0014, -0.0004));
  static final _i2 = CampusNode(id: 'x_2', type: CampusNodeType.intersection, location: _pt(0.0002, 0.0000));
  static final _i3 = CampusNode(id: 'x_3', type: CampusNodeType.intersection, location: _pt(0.0000, 0.0006));
  static final _i4 = CampusNode(id: 'x_4', type: CampusNodeType.intersection, location: _pt(0.0014, 0.0010));
  static final _i5 = CampusNode(id: 'x_5', type: CampusNodeType.intersection, location: _pt(0.0018, 0.0004));
  static final _i6 = CampusNode(id: 'x_6', type: CampusNodeType.intersection, location: _pt(-0.0014, 0.0002));

  static final List<CampusNode> _nodes = [
    mainGate, gate2East, gate3South, gate4West,
    csItBuilding, engineeringBuilding, library, adminBuilding,
    medicalCollege, mosque, studentCenter, cafeteria,
    _i1, _i2, _i3, _i4, _i5, _i6,
  ];

  /// A slightly bent line between two points, via one offset midpoint —
  /// enough to give guidance generation an actual turning point to detect,
  /// standing in for a real traced sidewalk shape.
  static List<GeoCoordinate> _bent(GeoCoordinate a, GeoCoordinate b, {double bend = 0.00015}) {
    final midLat = (a.latitude + b.latitude) / 2 + bend;
    final midLng = (a.longitude + b.longitude) / 2 - bend;
    return [a, GeoCoordinate(latitude: midLat, longitude: midLng), b];
  }

  static List<GeoCoordinate> _straight(GeoCoordinate a, GeoCoordinate b) => [a, b];

  static PathSegment _seg(String id, CampusNode from, CampusNode to, double shade, {bool bent = true}) {
    return PathSegment(
      id: id,
      fromNodeId: from.id,
      toNodeId: to.id,
      geometry: bent ? _bent(from.location, to.location) : _straight(from.location, to.location),
      shadeScore: shade,
    );
  }

  static final List<PathSegment> _segments = [
    // Main Gate side (open access road near the gate — low shade)
    _seg('seg_1', mainGate, _i1, 0.30),
    _seg('seg_2', _i1, gate3South, 0.30),
    // Direct bypass from the main-gate area straight toward the CS/Eng
    // cluster — the "shortest" option: short, but exposed.
    _seg('seg_3', _i1, _i4, 0.15, bent: false),
    // The scenic option: tree-lined central spine via the plaza —
    // longer, but noticeably more shaded overall.
    _seg('seg_4', _i1, _i2, 0.65),
    _seg('seg_5', _i2, _i3, 0.75),
    _seg('seg_6', _i2, _i4, 0.40), // the one exposed plaza crossing on this route
    // Library / Mosque cluster
    _seg('seg_7', _i3, library, 0.80),
    _seg('seg_8', _i3, mosque, 0.70),
    _seg('seg_9', _i2, studentCenter, 0.50),
    _seg('seg_10', _i2, cafeteria, 0.45),
    // CS/IT / Engineering / Gate 2 / Medical cluster
    _seg('seg_11', _i4, csItBuilding, 0.85),
    _seg('seg_12', _i4, engineeringBuilding, 0.50),
    _seg('seg_13', _i4, _i5, 0.30),
    _seg('seg_14', _i5, gate2East, 0.20),
    _seg('seg_15', _i5, medicalCollege, 0.35),
    // West side — Admin / Gate 4
    _seg('seg_16', _i2, _i6, 0.55),
    _seg('seg_17', _i6, adminBuilding, 0.60),
    _seg('seg_18', _i6, gate4West, 0.25),
    _seg('seg_19', gate3South, _i6, 0.45), // alternate south-west connector
  ];

  @override
  Future<List<CampusNode>> fetchNodes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _nodes;
  }

  @override
  Future<List<PathSegment>> fetchSegments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _segments;
  }
}
