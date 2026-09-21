import 'dart:math';

/// A plain lat/lng value — deliberately not `flutter_map`'s `LatLng` or
/// Firestore's `GeoPoint`. Domain and engine code (this file's package)
/// shouldn't depend on a mapping or database package; the presentation
/// layer converts to/from those at its own edges.
class GeoCoordinate {
  const GeoCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  static const _earthRadiusMeters = 6371000.0;

  double distanceInMetersTo(GeoCoordinate other) {
    final lat1 = latitude * pi / 180;
    final lat2 = other.latitude * pi / 180;
    final dLat = (other.latitude - latitude) * pi / 180;
    final dLng = (other.longitude - longitude) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  /// Initial compass bearing (0-360, 0 = north, clockwise) from this point
  /// to [other]. Used to detect turns along a path's geometry.
  double bearingDegreesTo(GeoCoordinate other) {
    final lat1 = latitude * pi / 180;
    final lat2 = other.latitude * pi / 180;
    final dLng = (other.longitude - longitude) * pi / 180;

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  @override
  bool operator ==(Object other) =>
      other is GeoCoordinate && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
