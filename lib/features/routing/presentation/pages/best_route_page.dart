import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../domain/entities/route_result.dart';
import '../widgets/alternative_route_row.dart';
import '../widgets/comfort_bar.dart';
import '../widgets/route_stat_chip.dart';
import 'route_guide_page.dart';

class BestRoutePage extends StatelessWidget {
  const BestRoutePage({super.key, required this.result});

  final RouteResult result;

  static const Color primaryGreen = Color(0xFF1E5B3D);
  static const Color primaryGreenLight = Color(0xFF2F7A55);

  double get _windFill {
    switch (result.windLabel) {
      case 'Calm':
        return 0.25;
      case 'Fair':
        return 0.5;
      case 'Breezy':
        return 0.75;
      default:
        return 1.0;
    }
  }

  String get _seasonWord {
    switch (result.seasonMode) {
      case SeasonMode.summer:
        return 'summer';
      case SeasonMode.winter:
        return 'winter';
      case SeasonMode.auto:
        return 'today\'s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (result.estimatedTime.inSeconds / 60).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryGreen, primaryGreenLight],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).maybePop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration:
                                BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_rounded, color: primaryGreen, size: 40),
                    ),
                    const SizedBox(height: 14),
                    const Text('Best Route Found!',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Optimized for $_seasonWord comfort',
                        style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFF6F8F7), borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 15, color: Color(0xFFE0A83C)),
                                const SizedBox(width: 6),
                                Text('RECOMMENDED ROUTE',
                                    style: TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _EndpointRow(icon: Icons.door_front_door_rounded, label: 'From', name: result.origin.name ?? '—'),
                            const Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: SizedBox(
                                height: 16,
                                child: VerticalDivider(width: 2, thickness: 1.5, color: Color(0xFFDDE5E1)),
                              ),
                            ),
                            _EndpointRow(icon: Icons.location_city_rounded, label: 'To', name: result.destination.name ?? '—'),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                RouteStatChip(
                                  icon: Icons.straighten_rounded,
                                  value: '${result.distanceMeters.round()} m',
                                  label: 'Distance',
                                  color: const Color(0xFF4C6FE0),
                                  backgroundColor: const Color(0xFFEAEEFD),
                                ),
                                const SizedBox(width: 8),
                                RouteStatChip(
                                  icon: Icons.schedule_rounded,
                                  value: '$minutes min',
                                  label: 'Est. Time',
                                  color: const Color(0xFFB8860B),
                                  backgroundColor: const Color(0xFFFDF6E3),
                                ),
                                const SizedBox(width: 8),
                                RouteStatChip(
                                  icon: Icons.eco_rounded,
                                  value: '${result.comfortScore.round()}%',
                                  label: 'Comfort',
                                  color: primaryGreen,
                                  backgroundColor: const Color(0xFFEAF3EE),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('COMFORT ANALYSIS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                      const SizedBox(height: 8),
                      ComfortBar(
                        emoji: '\ud83c\udf3f',
                        label: 'Shade',
                        value: result.shadePercent / 100,
                        trailing: '${result.shadePercent.round()}%',
                        color: primaryGreen,
                      ),
                      ComfortBar(
                        emoji: '\u2600\ufe0f',
                        label: 'Sun',
                        value: result.sunPercent / 100,
                        trailing: '${result.sunPercent.round()}%',
                        color: const Color(0xFFE0A83C),
                      ),
                      ComfortBar(
                        emoji: '\ud83d\udca8',
                        label: 'Wind',
                        value: _windFill,
                        trailing: result.windLabel,
                        color: const Color(0xFF4C6FE0),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFEAF3EE), borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('\ud83d\udca1', style: TextStyle(fontSize: 15)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(result.tip,
                                  style: const TextStyle(fontSize: 12.5, color: primaryGreen, height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                      if (result.alternatives.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        Text('ALTERNATIVE ROUTES',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                        const SizedBox(height: 10),
                        ...result.alternatives.map((alt) => AlternativeRouteRow(alternative: alt)),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => RouteGuidePage(result: result)),
                                );
                              },
                              icon: const Icon(Icons.menu_book_rounded, size: 17),
                              label: const Text('View Route'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: Route Details page using this same result.
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryGreen,
                                side: const BorderSide(color: Color(0xFFDDE5E1)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Details'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndpointRow extends StatelessWidget {
  const _EndpointRow({required this.icon, required this.label, required this.name});

  final IconData icon;
  final String label;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: const Color(0xFFEAF3EE), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: const Color(0xFF1E5B3D)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}
