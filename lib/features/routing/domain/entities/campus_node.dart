import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/geo_coordinate.dart';

/// Matches report Table 7 (`campus_nodes`), extended with `intersection` —
/// see the conversation this was designed in: destinations are what the
/// Select Route dropdowns show; intersections exist purely so the routing
/// engine has real alternate paths to compare, and never appear in the UI.
enum CampusNodeType { gate, buildingExternal, intersection }

class CampusNode extends Equatable {
  const CampusNode({
    required this.id,
    this.code,
    this.name,
    required this.type,
    required this.location,
  });

  final String id;
  final String? code;
  /// Null for intersections — they're never shown to the user, so they
  /// don't need a display name.
  final String? name;
  final CampusNodeType type;
  final GeoCoordinate location;

  bool get isSelectable => type != CampusNodeType.intersection;

  @override
  List<Object?> get props => [id, code, name, type, location];
}
