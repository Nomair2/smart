import '../../../../core/domain/entities/geo_coordinate.dart';
import '../../domain/entities/campus_node.dart';
import '../../domain/entities/path_segment.dart';
import '../../domain/repositories/campus_repository.dart';

/// Real pilot-area data for one corner of KKU's Al-Qariqir campus (Guraiger
/// district) — Building A, Building G, the Loco Cafe, the Library, and
/// Starbucks — replacing the earlier fully-fictional 12-destination set.
/// Smaller, but honest: everything here traces back to either a verified
/// coordinate or a specific photo, not an invented layout. See the
/// conversation this was built in for the source photo and reasoning.
///
/// ## What's actually verified vs. estimated
/// [starbucks]'s coordinate is real — confirmed against Google's own place
/// data (KKU Algreger Complex for Girls building, Guraiger/Al-Qariqir
/// district), not guessed. Every other node is positioned *relative to*
/// that one verified point, by reading pixel positions in an annotated
/// satellite photo and converting to a real-world offset using an assumed
/// scale (~0.85 m/pixel, based on the photo's approximate visible span —
/// not calibrated against a second known distance). That means: the
/// relative direction and shape of this layout should be trustworthy, but
/// the absolute distances between points are a reasonable estimate, not a
/// survey. Swap in real GPS coordinates (walked, or from a second verified
/// reference point) whenever they're available — nothing about the graph
/// structure below needs to change to accept better coordinates later.
///
/// ## Gate numbering is per-building, not campus-wide
/// Building A has gates 6, 9, and 11; Building G currently has one gate,
/// also numbered 9. Those are two different physical doors that happen to
/// share a number — node IDs disambiguate them (`bldg_a_gate_9` vs.
/// `bldg_g_gate_9`), and display names spell out which building each gate
/// belongs to so the Select Route dropdown is never ambiguous.
///
/// ## Still not real
/// `shadeScore` and `isPaved` below are still illustrative placeholders —
/// nothing about this update supplies real shade-survey data, only real
/// positions. The one node without a confirmed number is the north
/// entrance — its gate number wasn't legible in the source photo, so it's
/// modeled without one rather than inventing one.
class FakeCampusRepository implements CampusRepository {
  // Verified anchor — Google Places, not estimated.
  static const GeoCoordinate _starbucksLocation = GeoCoordinate(
    latitude: 18.249769,
    longitude: 42.558781,
  );

  static const _metersPerDegreeLat = 111320.0;
  // cos(18.25°) ≈ 0.9498 — longitude degrees are shorter than latitude
  // degrees this close to the equator-relative latitude of Abha.
  static const _metersPerDegreeLng = _metersPerDegreeLat * 0.9498;

  /// A point [metersNorth]/[metersEast] away from the verified Starbucks
  /// anchor — see the class doc comment for why this is an estimate, not a
  /// survey.
  static GeoCoordinate _relativeTo(
    GeoCoordinate anchor, {
    required double metersNorth,
    required double metersEast,
  }) {
    return GeoCoordinate(
      latitude: anchor.latitude + metersNorth / _metersPerDegreeLat,
      longitude: anchor.longitude + metersEast / _metersPerDegreeLng,
    );
  }

  // ---- Destinations ----
  static final CampusNode starbucks = CampusNode(
    id: 'starbucks',
    name: 'Starbucks',
    type: CampusNodeType.buildingExternal,
    location: _starbucksLocation,
  );

  static final CampusNode library = CampusNode(
    id: 'library_qariqir',
    name: 'Library',
    type: CampusNodeType.buildingExternal,
    location: _relativeTo(_starbucksLocation, metersNorth: 15, metersEast: -25),
  );

  static final CampusNode bldgAGate11 = CampusNode(
    id: 'bldg_a_gate_11',
    code: 'A11',
    name: 'Building A \u2014 Gate 11',
    type: CampusNodeType.gate,
    location: _relativeTo(_starbucksLocation, metersNorth: -64, metersEast: 30),
  );

  static final CampusNode bldgAGate9 = CampusNode(
    id: 'bldg_a_gate_9',
    code: 'A9',
    name: 'Building A \u2014 Gate 9',
    type: CampusNodeType.gate,
    location: _relativeTo(
      _starbucksLocation,
      metersNorth: -72,
      metersEast: 174,
    ),
  );

  static final CampusNode bldgAGate6 = CampusNode(
    id: 'bldg_a_gate_6',
    code: 'A6',
    name: 'Building A \u2014 Gate 6',
    type: CampusNodeType.gate,
    location: _relativeTo(
      _starbucksLocation,
      metersNorth: -140,
      metersEast: 323,
    ),
  );

  static final CampusNode bldgGGate9 = CampusNode(
    id: 'bldg_g_gate_9',
    code: 'G9',
    name: 'Building G \u2014 Gate 9',
    type: CampusNodeType.gate,
    location: _relativeTo(_starbucksLocation, metersNorth: 72, metersEast: 374),
  );

  static final CampusNode northGate = CampusNode(
    id: 'gate_north',
    name: 'North Entrance', // gate number not legible in the source photo
    type: CampusNodeType.gate,
    location: _relativeTo(
      _starbucksLocation,
      metersNorth: 174,
      metersEast: 391,
    ),
  );

  static final CampusNode cafeteria = CampusNode(
    id: 'cafeteria_loco',
    name: 'Loco Cafe',
    type: CampusNodeType.buildingExternal,
    location: _relativeTo(
      _starbucksLocation,
      metersNorth: -30,
      metersEast: 357,
    ),
  );

  // ---- One real branch point, where the path splits toward the
  // Library/Starbucks side vs. continuing on to Building A's gates ----
  static final CampusNode _junction = CampusNode(
    id: 'x_junction',
    type: CampusNodeType.intersection,
    location: _relativeTo(
      _starbucksLocation,
      metersNorth: -42,
      metersEast: 306,
    ),
  );

  static final List<CampusNode> _nodes = [
    starbucks,
    library,
    bldgAGate11,
    bldgAGate9,
    bldgAGate6,
    bldgGGate9,
    northGate,
    cafeteria,
    _junction,
  ];

  static List<GeoCoordinate> _straight(GeoCoordinate a, GeoCoordinate b) => [
    a,
    b,
  ];

  static PathSegment _seg(
    String id,
    CampusNode from,
    CampusNode to,
    double shade,
  ) {
    return PathSegment(
      id: id,
      fromNodeId: from.id,
      toNodeId: to.id,
      geometry: _straight(from.location, to.location),
      shadeScore: shade,
    );
  }

  static final List<PathSegment> _segments = [
    // North Entrance down past Building G's gate — open access road.
    _seg('seg_1', northGate, bldgGGate9, 0.25),
    // Building G's gate down to the Loco Cafe.
    _seg('seg_2', bldgGGate9, cafeteria, 0.45),
    // The branch point, right after the cafe.
    _seg('seg_3', cafeteria, _junction, 0.40),
    // West branch: toward the Library/Starbucks cluster.
    _seg('seg_4', _junction, bldgAGate11, 0.35),
    _seg('seg_5', bldgAGate11, library, 0.55),
    _seg('seg_6', library, starbucks, 0.60),
    // South branch: on to Building A's other two gates.
    _seg('seg_7', _junction, bldgAGate9, 0.30),
    _seg('seg_8', bldgAGate9, bldgAGate6, 0.35),
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
