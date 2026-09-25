import 'package:flutter/material.dart';

import '../../domain/entities/route_result.dart';
import '../widgets/comfort_band.dart';
import '../widgets/comfort_score_gauge.dart';
import '../widgets/comfort_bar.dart';
import '../widgets/weather_impact_grid.dart';
import '../widgets/weather_impact_style.dart';
import 'route_guide_page.dart';

/// Requirement A7 / report Fig25. A pure renderer, like Best Route Found
/// and Route Guide — every number here comes straight off the same
/// [RouteResult] the engine computed once; nothing on this page re-fetches
/// weather or re-runs the search.
class RouteDetailsPage extends StatelessWidget {
  const RouteDetailsPage({super.key, required this.result});

  final RouteResult result;

  static const Color primaryGreen = Color(0xFF1E5B3D);
  static const Color primaryGreenLight = Color(0xFF2F7A55);

  @override
  Widget build(BuildContext context) {
    final band = comfortBandFor(
      comfortScore: result.comfortScore,
      seasonMode: result.seasonMode,
      shadePercent: result.shadePercent,
    );
    final heatSafety =
        heatSafetyFor(temperatureC: result.weather.temperatureC, shadePercent: result.shadePercent);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Text('Route Details',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        SizedBox(width: 8),
                        Text('\ud83d\udcca', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.origin.name ?? '\u2014'} \u2192 ${result.destination.name ?? '\u2014'}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _OverviewCard(
                              icon: Icons.straighten_rounded,
                              value: '${result.distanceMeters.round()} m',
                              label: 'Total Distance',
                              detail: 'Outdoor walking path',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _OverviewCard(
                              icon: Icons.schedule_rounded,
                              value: '$minutes min',
                              label: 'Estimated Time',
                              detail: 'At normal walking pace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('COMFORT SCORE',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3EE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${result.comfortScore.round()}/100',
                                style: const TextStyle(
                                    fontSize: 11.5, fontWeight: FontWeight.w700, color: primaryGreen)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ComfortScoreGauge(comfortScore: result.comfortScore, band: band),
                      const SizedBox(height: 18),
                      ComfortBar(
                        emoji: '\ud83c\udf3f',
                        label: 'Shaded Coverage',
                        value: result.shadePercent / 100,
                        trailing: '${result.shadePercent.round()}%',
                        color: primaryGreen,
                      ),
                      ComfortBar(
                        emoji: '\u2600\ufe0f',
                        label: 'Direct Sun',
                        value: result.sunPercent / 100,
                        trailing: '${result.sunPercent.round()}%',
                        color: const Color(0xFFE0A83C),
                      ),
                      ComfortBar(
                        emoji: '\ud83c\udf2c\ufe0f',
                        label: 'Breeze',
                        value: result.naturalBreezePercent / 100,
                        trailing: '${result.naturalBreezePercent.round()}%',
                        color: const Color(0xFF4C6FE0),
                      ),
                      ComfortBar(
                        emoji: '\u267f',
                        label: 'Accessible',
                        value: result.pavedAccessiblePercent / 100,
                        trailing: '${result.pavedAccessiblePercent.round()}%',
                        color: const Color(0xFF7B4CE0),
                      ),
                      const SizedBox(height: 22),
                      Text('WEATHER IMPACT',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                      const SizedBox(height: 10),
                      WeatherImpactGrid(weather: result.weather, shadePercent: result.shadePercent),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFFDF6E3), borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 17, color: Color(0xFFB8860B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                heatSafetyTip(heatSafety: heatSafety),
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF8A6D1F), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => RouteGuidePage(result: result)),
                            );
                          },
                          icon: const Icon(Icons.navigation_rounded, size: 18),
                          label: const Text('Start Navigation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.icon, required this.value, required this.label, required this.detail});

  final IconData icon;
  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF6F8F7), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E5B3D)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(detail, style: TextStyle(fontSize: 10.5, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
