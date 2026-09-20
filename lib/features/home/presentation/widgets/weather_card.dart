import 'package:flutter/material.dart';

import '../../domain/entities/weather_snapshot.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.greeting,
    required this.firstName,
    required this.weather,
    required this.modeLabel,
    required this.onAvatarTap,
  });

  final String greeting;
  final String firstName;
  final WeatherSnapshot weather;
  final String modeLabel;
  final VoidCallback onAvatarTap;

  static const Color primaryGreen = Color(0xFF1E5B3D);
  static const Color primaryGreenLight = Color(0xFF2F7A55);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGreen, primaryGreenLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: primaryGreen.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6)),
                    const SizedBox(height: 2),
                    Text('$firstName 👋',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              InkWell(
                onTap: onAvatarTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 19),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(weather.locationLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
              ),
              const Text('Now', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${weather.temperatureC.round()}°',
                  style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800, height: 1)),
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 2),
                child: Text('C', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ),
            ],
          ),
          Text('${weather.condition} — $modeLabel',
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(icon: Icons.air_rounded, label: '${weather.windSpeedKph.round()} km/h'),
              _Chip(icon: Icons.thermostat_rounded, label: 'Feels ${weather.feelsLikeC.round()}°'),
              if (weather.isHeatAlert)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5C542),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 13, color: Colors.black87),
                      SizedBox(width: 4),
                      Text('Heat Alert',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.black87)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
