import 'package:flutter/material.dart';

import '../../../home/domain/entities/weather_snapshot.dart';
import 'weather_impact_style.dart';

/// The 2x2 "Weather Impact" grid — Temperature, UV Index, Wind Speed, Heat
/// Safety. The first three read straight off [WeatherSnapshot]; Heat
/// Safety is the one route-specific card (needs [shadePercent] too — see
/// `weather_impact_style.dart` for why).
class WeatherImpactGrid extends StatelessWidget {
  const WeatherImpactGrid({super.key, required this.weather, required this.shadePercent});

  final WeatherSnapshot weather;
  final double shadePercent;

  @override
  Widget build(BuildContext context) {
    final temp = temperatureBand(weather.temperatureC);
    final heatSafety = heatSafetyFor(temperatureC: weather.temperatureC, shadePercent: shadePercent);
    final uv = weather.uvIndex != null ? uvBand(weather.uvIndex!) : null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _WeatherStatCard(
                icon: Icons.thermostat_rounded,
                iconColor: const Color(0xFFE0574C),
                backgroundColor: const Color(0xFFFDEBEA),
                value: '${weather.temperatureC.round()}\u00b0C',
                label: temp.label,
                detail: temp.detail,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: uv == null
                  ? const _WeatherStatCard(
                      icon: Icons.wb_sunny_rounded,
                      iconColor: Color(0xFFB8860B),
                      backgroundColor: Color(0xFFFDF6E3),
                      value: '\u2014',
                      label: 'UV Index',
                      detail: 'Not available',
                    )
                  : _WeatherStatCard(
                      icon: Icons.wb_sunny_rounded,
                      iconColor: const Color(0xFFB8860B),
                      backgroundColor: const Color(0xFFFDF6E3),
                      value: '${weather.uvIndex!.round()} / 11',
                      label: 'UV Index',
                      detail: uv.label,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _WeatherStatCard(
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF4C6FE0),
                backgroundColor: const Color(0xFFEAEEFD),
                value: '${weather.windSpeedKph.round()} km/h',
                label: 'Wind Speed',
                detail: _windDetail(weather.windSpeedKph),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WeatherStatCard(
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF1E5B3D),
                backgroundColor: const Color(0xFFEAF3EE),
                value: heatSafety.label,
                label: 'Heat Safety',
                detail: heatSafety.detail,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _windDetail(double kph) {
    if (kph < 8) return 'Calm';
    if (kph < 20) return 'Light breeze';
    if (kph < 35) return 'Breezy';
    return 'Strong wind';
  }
}

class _WeatherStatCard extends StatelessWidget {
  const _WeatherStatCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.value,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: iconColor)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
          Text(detail, style: TextStyle(fontSize: 10.5, color: iconColor.withOpacity(0.85))),
        ],
      ),
    );
  }
}
