import '../../../core/domain/entities/geo_coordinate.dart';
import '../domain/entities/campus_node.dart';
import '../domain/entities/path_segment.dart';

/// THE file to edit when you survey the real campus. Nothing else in the
/// routing feature needs to change when coordinates do.
///
/// ## How the map is modelled
/// * **Destinations** (gates, buildings, cafes) — what the Select Route
///   dropdowns show. One absolute coordinate each.
/// * **Intersections** — points where the walking network really forks
///   (a side path leaves the main road). Never shown in the UI, but the
///   routing engine needs them: without a node at the fork, A* has nothing
///   to choose between.
/// * **Turning points** — bends in a *single* path. These are NOT nodes;
///   put them in a segment's `via:` list. That is what makes the drawn
///   route (and the turn-by-turn instructions) follow the real sidewalk
///   instead of cutting straight between two doors.
///
/// ## Every coordinate here is absolute
/// Earlier versions positioned everything as "N metres / E metres from
/// Starbucks", so moving the Starbucks coordinate just slid the whole guessed
/// shape along with it. Now each node stands alone: changing one node's
/// `_p(lat, lng)` moves only that node.
///
/// ## Workflow for getting real numbers
/// 1. Run the app in debug mode, open Routes, **long-press the "Select
///    Route" title** — that opens the campus data check map.
/// 2. Tap the exact spot of a gate/door/junction; tap "Copy points"; paste
///    the `_p(...)` line over the node's placeholder below.
/// 3. Add its id to [verifiedNodeIds] — the marker turns from orange
///    (estimated) to green (checked).
/// 4. For a curved path, tap along the sidewalk at each real bend, copy,
///    and paste the lines into that segment's `via: [...]`.
/// 5. Static fields are not re-run by hot reload — use **hot restart**
///    after editing this file.
///
/// ## Still illustrative
/// The placeholder coordinates below are estimates read off a photo (see
/// history) — only Starbucks is a real, checked coordinate. `shadeScore`
/// values are also placeholders; positions do not tell us anything about
/// shade. Gate numbers are per-building: Building A's Gate 9 and Building
/// G's Gate 9 are different doors, hence distinct ids.
class CampusMapData {
  const CampusMapData._();

  /// Node ids whose coordinate you have checked on the real map. Anything
  /// not listed shows as orange ("estimated") on the debug map.
  static const Set<String> verifiedNodeIds = {'starbucks'};

  static GeoCoordinate _p(double lat, double lng) =>
      GeoCoordinate(latitude: lat, longitude: lng);

  // ------------------------------------------------------------------
  // DESTINATIONS
  // ------------------------------------------------------------------
  static final CampusNode starbucks = CampusNode(
    id: 'starbucks',
    name: 'Starbucks',
    type: CampusNodeType.buildingExternal,
    location: _p(18.2497640, 42.5587653), // checked
  );

  static final CampusNode library = CampusNode(
    id: 'library_qariqir',
    name: 'Library',
    type: CampusNodeType.buildingExternal,
    location: _p(18.2488562, 42.5589474), // ESTIMATED — replace
  );

  static final CampusNode cafeteria = CampusNode(
    id: 'cafeteria_loco',
    name: 'Loco Cafe',
    type: CampusNodeType.buildingExternal,
    location: _p(18.2478039, 42.5597990), // ESTIMATED — replace
  );

  static final CampusNode bldgAGate11 = CampusNode(
    id: 'bldg_a_gate_11',
    code: 'A11',
    name: 'Building A \u2014 Gate 11',
    type: CampusNodeType.gate,
    location: _p(18.2495290, 42.5579178), // ESTIMATED — replace
  );

  static final CampusNode bldgAGate9 = CampusNode(
    id: 'bldg_a_gate_9',
    code: 'A9',
    name: 'Building A \u2014 Gate 9',
    type: CampusNodeType.gate,
    location: _p(18.2487180, 42.5586228), // ESTIMATED — replace
  );

  static final CampusNode bldgAGate6 = CampusNode(
    id: 'bldg_a_gate_6',
    code: 'A6',
    name: 'Building A \u2014 Gate 6',
    type: CampusNodeType.gate,
    location: _p(18.2474453, 42.5588347), // ESTIMATED — replace
  );

  static final CampusNode bldgGGate9 = CampusNode(
    id: 'bldg_g_gate_9',
    code: 'G9',
    name: 'Building G \u2014 Gate 9',
    type: CampusNodeType.gate,
    location: _p(18.2481293, 42.5603093), // ESTIMATED — replace
  );

  static final CampusNode northGate = CampusNode(
    id: 'gate_north',
    name: 'North Entrance', // number not legible in the source photo
    type: CampusNodeType.gate,
    location: _p(18.2485588, 42.5611227), // ESTIMATED — replace
  );

  // ------------------------------------------------------------------
  // INTERSECTIONS — where a side path leaves the main walkway.
  // Reading of the source photo: a main walkway runs west from near the
  // cafe to Starbucks, with short branches ("teeth") to Building A's
  // gates 6, 9 and 11. Correct this if the real layout differs.
  // ------------------------------------------------------------------
  static final CampusNode xCafe = CampusNode(
    id: 'x_cafe',
    type: CampusNodeType.intersection,
    location: _p(18.2478347, 42.5598245), // ESTIMATED — replace
  );

  static final CampusNode xGate6 = CampusNode(
    id: 'x_gate6',
    type: CampusNodeType.intersection,
    location: _p(18.2477456, 42.5589635), // ESTIMATED — replace
  );

  static final CampusNode xGate9 = CampusNode(
    id: 'x_gate9',
    type: CampusNodeType.intersection,
    location: _p(18.2488142, 42.5588673), // ESTIMATED — replace
  );

  static final CampusNode xGate11 = CampusNode(
    id: 'x_gate11',
    type: CampusNodeType.intersection,
    location: _p(18.2498525, 42.5580747), // ESTIMATED — replace
  );
  //
  static final CampusNode xintersection1 = CampusNode(
    id: 'x_intersection_1',
    type: CampusNodeType.intersection,
    location: _p(18.2497006, 42.5584827), // ESTIMATED — replace
  );
  static final CampusNode xintersection2 = CampusNode(
    id: 'x_intersection_2',
    type: CampusNodeType.intersection,
    location: _p(18.2480086, 42.5597061), // ESTIMATED — replace
  );

  static final CampusNode xintersection3 = CampusNode(
    id: 'x_intersection_3',
    type: CampusNodeType.intersection,
    location: _p(18.2483156, 42.5595254), // ESTIMATED — replace
  );
  static final CampusNode xintersection4 = CampusNode(
    id: 'x_intersection_4',
    type: CampusNodeType.intersection,
    location: _p(18.2483522, 42.5591046), // ESTIMATED — replace
  );
  static final CampusNode xintersection5 = CampusNode(
    id: 'x_intersection_5',
    type: CampusNodeType.intersection,
    location: _p(18.2479115, 42.5592827), // ESTIMATED — replace
  );

  static final CampusNode xintersection6 = CampusNode(
    id: 'x_intersection_6',
    type: CampusNodeType.intersection,
    location: _p(18.2492100, 42.5586946), // ESTIMATED — replace
  );

  static final CampusNode xintersection7 = CampusNode(
    id: 'x_intersection_7',
    type: CampusNodeType.intersection,
    location: _p(18.2493265, 42.5589839), // ESTIMATED — replace
  );
  static final CampusNode xGGate9 = CampusNode(
    id: 'x_G_gate9',
    type: CampusNodeType.intersection,
    location: _p(18.2482888, 42.5602268), // ESTIMATED — replace
  );

  static final CampusNode xGGateN = CampusNode(
    id: 'x_G_gateN',
    type: CampusNodeType.intersection,
    location: _p(18.2487031, 42.5610352), // ESTIMATED — replace
  );

  static final List<CampusNode> nodes = [
    starbucks,
    library,
    cafeteria,
    bldgAGate11,
    bldgAGate9,
    bldgAGate6,
    bldgGGate9,
    northGate,
    xCafe,
    xGate6,
    xGate9,
    xGate11,
    xGGate9,
    xintersection1,
    xGGateN,
    xintersection2,
    xintersection3,
    xintersection4,
    xintersection5,
    xintersection6,
    xintersection7,
  ];

  // ------------------------------------------------------------------
  // SEGMENTS — the walkable links between two nodes.
  //   _seg(id, from, to, shade, via: [ ...turning points, in order... ])
  // `via` is optional: leave it out for a truly straight stretch. The
  // segment's shape is [from, ...via, to], so its ends always follow the
  // node coordinates above.
  //
  // Example of tracing a bend (paste the lines the debug map copies):
  //   _seg('seg_4', xCafe, xGate6, 0.30, via: [
  //     _p(18.249500, 42.561100),
  //     _p(18.249400, 42.560850),
  //   ]),
  // ------------------------------------------------------------------
  static PathSegment _seg(
    String id,
    CampusNode from,
    CampusNode to,
    double shade, {
    List<GeoCoordinate> via = const [],
  }) {
    return PathSegment(
      id: id,
      fromNodeId: from.id,
      toNodeId: to.id,
      geometry: [from.location, ...via, to.location],
      shadeScore: shade,
    );
  }

  static final List<PathSegment> segments = [
    // North Entrance south past Building G's gate, to the cafe fork.
    _seg('seg_2', northGate, xGGateN, 0.40),
    _seg('seg_1', xGGateN, xGGate9, 0.25),

    _seg('seg_12', xintersection2, xCafe, 0.40),
    _seg('seg_2', xGGate9, xintersection2, 0.40),
    _seg('seg_13', bldgGGate9, xGGate9, 0.40),
    _seg('seg_3', xCafe, cafeteria, 0.45), // short spur to the cafe
    // Main walkway heading west; each fork has a short tooth to a gate.
    _seg('seg_14', xintersection2, xintersection3, 0.30),
    _seg('seg_15', xintersection3, xintersection4, 0.30),
    _seg('seg_16', xintersection3, xintersection4, 0.30),
    _seg('seg_17', xintersection4, xintersection5, 0.30),

    _seg('seg_4', xintersection5, xGate6, 0.30),
    _seg('seg_5', xGate6, bldgAGate6, 0.35),
    _seg('seg_6', xintersection4, xGate9, 0.35),
    _seg('seg_7', xGate9, bldgAGate9, 0.30),
    _seg('seg_8', xintersection1, xintersection6, 0.40),
    _seg('seg_18', xGate9, xintersection6, 0.40),
    _seg('seg_20', xGate9, library, 0.40),
    _seg('seg_19', xintersection6, xintersection7, 0.40),
    _seg('seg_10', xintersection7, starbucks, 0.40),

    _seg('seg_9', xGate11, bldgAGate11, 0.35),
    _seg('seg_14', xGate11, xintersection1, 0.35),
    // West end: Starbucks and the Library.
    // _seg('seg_10', xGate11, starbucks, 0.55),
    // _seg('seg_11', starbucks, library, 0.60),
  ];
}
