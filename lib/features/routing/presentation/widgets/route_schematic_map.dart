import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/domain/entities/geo_coordinate.dart';

class RouteSchematicMap extends StatefulWidget {
  const RouteSchematicMap({
    super.key,
    required this.geometry,
    required this.progress,
    this.userLatitude,
    this.userLongitude,
    this.followUser = false,
    this.height = 220,
  });

  final List<GeoCoordinate> geometry;

  /// Used only for preview mode.
  ///
  /// When real GPS coordinates are available,
  /// the GPS position is used instead.
  final double progress;

  /// Real GPS latitude.
  final double? userLatitude;

  /// Real GPS longitude.
  final double? userLongitude;

  /// Whether the camera should follow the user.
  final bool followUser;

  final double height;

  static const Color primaryGreen = Color(0xFF1E5B3D);

  static const Color destinationRed = Color(0xFFE0574C);

  static const Color userBlue = Color(0xFF1976D2);

  static const LatLng _placeholderCenter = LatLng(18.0976, 42.7206);

  @override
  State<RouteSchematicMap> createState() => _RouteSchematicMapState();
}

class _RouteSchematicMapState extends State<RouteSchematicMap> {
  final MapController _mapController = MapController();

  List<LatLng> get _points {
    return widget.geometry.map((g) => LatLng(g.latitude, g.longitude)).toList();
  }

  bool get _hasUserLocation =>
      widget.userLatitude != null && widget.userLongitude != null;

  LatLng? get _userPosition {
    if (!_hasUserLocation) {
      return null;
    }

    return LatLng(widget.userLatitude!, widget.userLongitude!);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
    });
  }

  @override
  void didUpdateWidget(covariant RouteSchematicMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.geometry != widget.geometry) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });

      return;
    }

    if (widget.followUser &&
        _userPosition != null &&
        oldWidget.userLatitude != widget.userLatitude &&
        oldWidget.userLongitude != widget.userLongitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _moveCameraToUser();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitBounds() {
    final points = _points;

    if (points.length < 2 || !mounted) {
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(32),
      ),
    );
  }

  void _moveCameraToUser() {
    final position = _userPosition;

    if (position == null || !mounted) {
      return;
    }

    _mapController.move(position, 18);
  }

  /// Preview position used before GPS navigation starts.
  ///
  /// Once GPS becomes available, this method is ignored.
  LatLng? _previewPosition(List<LatLng> points, double fraction) {
    if (points.isEmpty) {
      return null;
    }

    if (points.length < 2) {
      return points.first;
    }

    const distanceCalc = Distance();

    final segmentLengths = <double>[];

    var total = 0.0;

    for (var i = 1; i < points.length; i++) {
      final distance = distanceCalc(points[i - 1], points[i]);

      segmentLengths.add(distance);

      total += distance;
    }

    if (total == 0) {
      return points.first;
    }

    var target = total * fraction.clamp(0.0, 1.0);

    for (var i = 0; i < segmentLengths.length; i++) {
      final segmentLength = segmentLengths[i];

      if (target <= segmentLength) {
        final t = segmentLength == 0 ? 0.0 : target / segmentLength;

        return LatLng(
          points[i].latitude +
              (points[i + 1].latitude - points[i].latitude) * t,
          points[i].longitude +
              (points[i + 1].longitude - points[i].longitude) * t,
        );
      }

      target -= segmentLength;
    }

    return points.last;
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;

    /*
     * IMPORTANT:
     *
     * If GPS exists:
     *      GPS location
     *
     * Otherwise:
     *      old preview position
     */
    final current = _hasUserLocation
        ? _userPosition
        : _previewPosition(points, widget.progress);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: points.isNotEmpty
                ? points.first
                : RouteSchematicMap._placeholderCenter,
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
              userAgentPackageName: 'com.example.smartpath',
              maxZoom: 19,
            ),

            /*
             * REAL ROUTE
             */
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

            /*
             * MARKERS
             */
            MarkerLayer(
              markers: [
                /*
                 * START
                 */
                if (points.isNotEmpty)
                  Marker(
                    point: points.first,
                    width: 22,
                    height: 22,
                    child: const _StartMarker(
                      color: RouteSchematicMap.primaryGreen,
                    ),
                  ),

                /*
                 * DESTINATION
                 */
                if (points.length > 1)
                  Marker(
                    point: points.last,
                    width: 30,
                    height: 30,
                    child: const _DestinationMarker(
                      color: RouteSchematicMap.destinationRed,
                    ),
                  ),

                /*
                 * USER
                 *
                 * This is now the REAL GPS
                 * location.
                 */
                if (current != null)
                  Marker(
                    point: current,
                    width: 44,
                    height: 44,
                    child: _CurrentPositionMarker(
                      color: RouteSchematicMap.userBlue,
                      isRealLocation: _hasUserLocation,
                    ),
                  ),
              ],
            ),
          ],
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
  const _CurrentPositionMarker({
    required this.color,
    required this.isRealLocation,
  });

  final Color color;
  final bool isRealLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.35),
          width: isRealLocation ? 4 : 2,
        ),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Center(
        child: Container(
          width: isRealLocation ? 14 : 10,
          height: isRealLocation ? 14 : 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
