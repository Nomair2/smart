import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/domain/entities/geo_coordinate.dart';

/// A real street map (OpenStreetMap tiles via `flutter_map`, both free/
/// open-source — no API key, no billing account) showing the actual
/// route: start/destination/current-position markers over real streets.
/// This replaces the earlier abstract, custom-drawn schematic version
/// and fulfils report requirement C6 (real basemap rendering) that the
/// schematic deliberately deferred.
///
/// Tile provider: the public `tile.openstreetmap.org` server. It's free
/// and needs no signup, but OSM's tile usage policy asks for a genuine
/// `userAgentPackageName` (see below — replace the placeholder with
/// your app's actual applicationId) and reasonable request volume; if
/// this app gets real traffic, move to a free-tier provider meant for
/// production apps (MapTiler, Stadia Maps, Thunderforest all have free
/// tiers with sign-up) or self-host tiles instead of hammering OSM's
/// donated server directly.
class RouteSchematicMap extends StatefulWidget {
  const RouteSchematicMap({
    super.key,
    required this.geometry,
    required this.progress,
    this.height = 220,
  });

  final List<GeoCoordinate> geometry;

  /// 0.0-1.0 fraction along the route, for placing the "current position"
  /// marker. Driven by `currentStepIndex / (steps - 1)` rather than true
  /// GPS — see the design note on manual step advancement.
  final double progress;

  final double height;

  static const Color primaryGreen = Color(0xFF1E5B3D);
  static const Color destinationRed = Color(0xFFE0574C);

  // Approximate — the KKU Stadium, which sits on the Abha campus — used
  // only to center the map before real geometry arrives. Swap for an
  // actual campus-center coordinate once you have one.
  static const LatLng _placeholderCenter = LatLng(18.0976, 42.7206);

  @override
  State<RouteSchematicMap> createState() => _RouteSchematicMapState();
}

class _RouteSchematicMapState extends State<RouteSchematicMap> {
  final MapController _mapController = MapController();

  List<LatLng> get _points =>
      widget.geometry.map((g) => LatLng(g.latitude, g.longitude)).toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
  }

  @override
  void didUpdateWidget(covariant RouteSchematicMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.geometry != widget.geometry) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitBounds() {
    final points = _points;
    if (points.length < 2 || !mounted) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(32),
      ),
    );
  }

  /// Interpolates along the route geometry by great-circle distance —
  /// the geographic equivalent of the old pixel-space _pointAtFraction.
  LatLng? _currentPosition(List<LatLng> points, double fraction) {
    if (points.isEmpty) return null;
    if (points.length < 2) return points.first;

    const distanceCalc = Distance();
    final segmentLengths = <double>[];
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      final d = distanceCalc(points[i - 1], points[i]);
      segmentLengths.add(d);
      total += d;
    }
    if (total == 0) return points.first;

    var target = total * fraction.clamp(0, 1);
    for (var i = 0; i < segmentLengths.length; i++) {
      if (target <= segmentLengths[i]) {
        final t = segmentLengths[i] == 0 ? 0.0 : target / segmentLengths[i];
        return LatLng(
          points[i].latitude +
              (points[i + 1].latitude - points[i].latitude) * t,
          points[i].longitude +
              (points[i + 1].longitude - points[i].longitude) * t,
        );
      }
      target -= segmentLengths[i];
    }
    return points.last;
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;
    final current = _currentPosition(points, widget.progress);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(18.247727, 42.559913),
            // points.isNotEmpty
            //     ? points.first
            //     : RouteSchematicMap._placeholderCenter,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags:
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.drag |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // Replace with this app's real applicationId (see
              // android/app/build.gradle or ios Info.plist) before
              // shipping — required by OSM's tile usage policy.
              userAgentPackageName: 'com.example.smartpath',
              maxZoom: 19,
            ),
            if (points.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    color: RouteSchematicMap.primaryGreen,
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (points.isNotEmpty)
                  Marker(
                    point: points.first,
                    width: 22,
                    height: 22,
                    child: _StartMarker(color: RouteSchematicMap.primaryGreen),
                  ),
                if (points.length > 1)
                  Marker(
                    point: points.last,
                    width: 30,
                    height: 30,
                    child: _DestinationMarker(
                      color: RouteSchematicMap.destinationRed,
                    ),
                  ),
                if (current != null)
                  Marker(
                    point: current,
                    width: 26,
                    height: 26,
                    child: _CurrentPositionMarker(
                      color: RouteSchematicMap.primaryGreen,
                    ),
                  ),
              ],
            ),
          ],
          // nonRotatedChildren: [
          //   AttributionWidget.defaultWidget(
          //     source: 'OpenStreetMap contributors',
          //     onSourceTapped: null,
          //   ),
          // ],
        ),
      ),
    );
  }
}

class _StartMarker extends StatelessWidget {
  const _StartMarker({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: const Icon(Icons.flag, color: Colors.white, size: 14),
    );
  }
}

class _CurrentPositionMarker extends StatelessWidget {
  const _CurrentPositionMarker({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
