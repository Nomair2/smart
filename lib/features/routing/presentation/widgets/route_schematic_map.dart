import 'package:flutter/material.dart';

import '../../../../core/domain/entities/geo_coordinate.dart';

/// A lightweight, custom-drawn stand-in for a real basemap — not
/// `flutter_map`. The mockup's map is itself an abstract schematic (flat
/// building blocks, a dashed line, simple markers), not real tile imagery,
/// so this matches what's actually being asked for rather than defaulting
/// to OSM tiles, which would need a tile-provider decision and a new
/// dependency neither of which this screen needs to make that call on.
/// Real basemap rendering (report requirement C6) is a deliberate later
/// upgrade, not something this widget is standing in to fake.
class RouteSchematicMap extends StatelessWidget {
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

  static const Color _background = Color(0xFFDCEAE0);
  static const Color _building = Color(0xFFC3DBCB);
  static const Color primaryGreen = Color(0xFF1E5B3D);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRect(
        child: CustomPaint(
          painter: _SchematicPainter(geometry: geometry, progress: progress.clamp(0, 1)),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SchematicPainter extends CustomPainter {
  _SchematicPainter({required this.geometry, required this.progress});

  final List<GeoCoordinate> geometry;
  final double progress;

  static const Color _background = RouteSchematicMap._background;
  static const Color _building = RouteSchematicMap._building;
  static const Color primaryGreen = RouteSchematicMap.primaryGreen;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _background);
    _drawDecorativeBuildings(canvas, size);

    if (geometry.length < 2) return;

    final points = _project(geometry, size, padding: 28);
    _drawDashedPath(canvas, points);

    // Start marker
    _drawDot(canvas, points.first, 6, primaryGreen, border: true);
    // Destination marker (simple pin)
    _drawPin(canvas, points.last, const Color(0xFFE0574C));
    // Current-position marker, interpolated along the projected path.
    final current = _pointAtFraction(points, progress);
    _drawCurrentPositionMarker(canvas, current);
  }

  void _drawDecorativeBuildings(Canvas canvas, Size size) {
    // Fixed, non-random layout — illustrative building blocks, not tied to
    // real footprints (no building geometry data exists for that yet).
    final rects = [
      Rect.fromLTWH(size.width * 0.06, size.height * 0.10, size.width * 0.22, size.height * 0.28),
      Rect.fromLTWH(size.width * 0.06, size.height * 0.55, size.width * 0.22, size.height * 0.30),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.08, size.width * 0.22, size.height * 0.26),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.58, size.width * 0.22, size.height * 0.28),
      Rect.fromLTWH(size.width * 0.40, size.height * 0.06, size.width * 0.20, size.height * 0.18),
    ];
    final paint = Paint()..color = _building;
    for (final rect in rects) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), paint);
    }
  }

  List<Offset> _project(List<GeoCoordinate> points, Size size, {required double padding}) {
    var minLat = points.first.latitude, maxLat = points.first.latitude;
    var minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final latSpan = (maxLat - minLat).abs() < 1e-9 ? 1e-9 : (maxLat - minLat);
    final lngSpan = (maxLng - minLng).abs() < 1e-9 ? 1e-9 : (maxLng - minLng);

    final usableWidth = size.width - padding * 2;
    final usableHeight = size.height - padding * 2;

    return points.map((p) {
      final normX = (p.longitude - minLng) / lngSpan;
      final normY = (p.latitude - minLat) / latSpan;
      // Latitude increases northward (up on screen), so flip Y.
      return Offset(
        padding + normX * usableWidth,
        padding + (1 - normY) * usableHeight,
      );
    }).toList();
  }

  void _drawDashedPath(Canvas canvas, List<Offset> points) {
    final paint = Paint()
      ..color = primaryGreen
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const dashLength = 7.0;
    const gapLength = 5.0;
    var drawingDash = true;
    var remaining = dashLength;

    for (var i = 1; i < points.length; i++) {
      var start = points[i - 1];
      final end = points[i];
      var segmentLength = (end - start).distance;
      final direction = segmentLength == 0 ? Offset.zero : (end - start) / segmentLength;

      while (segmentLength > 0) {
        final step = remaining < segmentLength ? remaining : segmentLength;
        final next = start + direction * step;
        if (drawingDash) {
          canvas.drawLine(start, next, paint);
        }
        start = next;
        segmentLength -= step;
        remaining -= step;
        if (remaining <= 0) {
          drawingDash = !drawingDash;
          remaining = drawingDash ? dashLength : gapLength;
        }
      }
    }
  }

  Offset _pointAtFraction(List<Offset> points, double fraction) {
    if (points.length < 2) return points.first;
    final segmentLengths = <double>[];
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      final len = (points[i] - points[i - 1]).distance;
      segmentLengths.add(len);
      total += len;
    }
    if (total == 0) return points.first;

    var target = total * fraction;
    for (var i = 0; i < segmentLengths.length; i++) {
      if (target <= segmentLengths[i]) {
        final t = segmentLengths[i] == 0 ? 0.0 : target / segmentLengths[i];
        return Offset.lerp(points[i], points[i + 1], t)!;
      }
      target -= segmentLengths[i];
    }
    return points.last;
  }

  void _drawDot(Canvas canvas, Offset center, double radius, Color color, {bool border = false}) {
    canvas.drawCircle(center, radius, Paint()..color = color);
    if (border) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawPin(Canvas canvas, Offset tip, Color color) {
    final paint = Paint()..color = color;
    final center = tip.translate(0, -10);
    canvas.drawCircle(center, 9, paint);
    final path = Path()
      ..moveTo(center.dx - 6, center.dy + 5)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(center.dx + 6, center.dy + 5)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
  }

  void _drawCurrentPositionMarker(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 12, Paint()..color = Colors.black26);
    canvas.drawCircle(center, 11, Paint()..color = Colors.white);
    canvas.drawCircle(center, 5, Paint()..color = primaryGreen);
  }

  @override
  bool shouldRepaint(covariant _SchematicPainter oldDelegate) {
    return oldDelegate.geometry != geometry || oldDelegate.progress != progress;
  }
}
