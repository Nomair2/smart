import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/campus_map_data.dart';
import '../../domain/entities/campus_node.dart';
import '../../domain/entities/path_segment.dart';
import '../../domain/repositories/campus_repository.dart';

/// Developer tool — reached by long-pressing the "Select Route" title in a
/// debug build. Two jobs:
///
/// 1. **Check**: draws every node and segment from the [CampusRepository]
///    over the real OSM tiles, so you can see immediately whether a
///    coordinate lands on the right door. Green = listed in
///    `CampusMapData.verifiedNodeIds`, orange = still an estimate, grey =
///    an intersection.
/// 2. **Capture**: tap anywhere on the map to drop a numbered point; "Copy
///    points" puts them on the clipboard as `_p(lat, lng),` lines, ready to
///    paste over a node's coordinate or into a segment's `via: [...]`.
class CampusDebugMapPage extends StatefulWidget {
  const CampusDebugMapPage({super.key});

  @override
  State<CampusDebugMapPage> createState() => _CampusDebugMapPageState();
}

class _CampusDebugMapPageState extends State<CampusDebugMapPage> {
  static const Color _green = Color(0xFF1E5B3D);
  static const Color _estimated = Color(0xFFE08A1E);
  static const Color _intersection = Color(0xFF6B7A72);

  List<CampusNode>? _nodes;
  List<PathSegment> _segments = const [];
  String? _error;
  final List<LatLng> _drafted = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = context.read<CampusRepository>();
    try {
      final nodes = await repository.fetchNodes();
      final segments = await repository.fetchSegments();
      if (!mounted) return;
      setState(() {
        _nodes = nodes;
        _segments = segments;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  LatLng _latLng(double lat, double lng) => LatLng(lat, lng);

  Future<void> _copyPoints() async {
    if (_drafted.isEmpty) return;
    final code = _drafted
        .map(
          (p) =>
              '_p(${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}),',
        )
        .join('\n');
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Copied ${_drafted.length} point(s)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _nodes;
    return Scaffold(
      appBar: AppBar(title: const Text('Campus data check')),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!),
              ),
            )
          : nodes == null
          ? const Center(child: CircularProgressIndicator())
          : _buildMap(nodes),
    );
  }

  Widget _buildMap(List<CampusNode> nodes) {
    final allPoints = <LatLng>[
      for (final n in nodes) _latLng(n.location.latitude, n.location.longitude),
      for (final s in _segments)
        for (final g in s.geometry) _latLng(g.latitude, g.longitude),
    ];
    final last = _drafted.isEmpty ? null : _drafted.last;

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCameraFit: allPoints.length >= 2
                ? CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(allPoints),
                    padding: const EdgeInsets.all(56),
                  )
                : null,
            initialCenter: allPoints.isNotEmpty
                ? allPoints.first
                : const LatLng(18.2497, 42.5587),
            initialZoom: 18,
            onTap: (tapPosition, point) => setState(() => _drafted.add(point)),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.smartpath',
              maxZoom: 19,
            ),
            PolylineLayer(
              polylines: [
                for (final s in _segments)
                  Polyline(
                    points: [
                      for (final g in s.geometry)
                        _latLng(g.latitude, g.longitude),
                    ],
                    color: _green,
                    strokeWidth: 4,
                  ),
                if (_drafted.length >= 2)
                  Polyline(
                    points: _drafted,
                    color: Colors.deepOrange,
                    strokeWidth: 3,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (final n in nodes) _nodeMarker(n),
                for (var i = 0; i < _drafted.length; i++)
                  Marker(
                    point: _drafted[i],
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      _LegendDot(color: _green, label: 'checked'),
                      SizedBox(width: 14),
                      _LegendDot(color: _estimated, label: 'estimated'),
                      SizedBox(width: 14),
                      _LegendDot(color: _intersection, label: 'intersection'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    last == null
                        ? 'Tap the map to drop points along a path or on a door.'
                        : '${_drafted.length} point(s) \u2014 last: '
                              '${last.latitude.toStringAsFixed(6)}, ${last.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _drafted.isEmpty ? null : _copyPoints,
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy points'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _drafted.isEmpty
                            ? null
                            : () => setState(_drafted.removeLast),
                        child: const Text('Undo'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _drafted.isEmpty
                            ? null
                            : () => setState(_drafted.clear),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Marker _nodeMarker(CampusNode node) {
    final Color color;
    if (!node.isSelectable) {
      color = _intersection;
    } else if (CampusMapData.verifiedNodeIds.contains(node.id)) {
      color = _green;
    } else {
      color = _estimated;
    }
    final label = node.isSelectable ? (node.name ?? node.id) : node.id;

    return Marker(
      point: _latLng(node.location.latitude, node.location.longitude),
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          Positioned(
            bottom: 16,
            left: -60,
            right: -60,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11.5)),
      ],
    );
  }
}
