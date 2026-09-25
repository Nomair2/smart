import 'package:flutter/material.dart';

import 'comfort_band.dart';

/// The circular comfort-score ring plus its label and description —
/// [comfortBandFor] does the classification, this widget just renders it.
class ComfortScoreGauge extends StatelessWidget {
  const ComfortScoreGauge({super.key, required this.comfortScore, required this.band});

  final double comfortScore;
  final ComfortBand band;

  static const Color primaryGreen = Color(0xFF1E5B3D);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: (comfortScore / 100).clamp(0, 1),
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFEDF0EF),
                  valueColor: const AlwaysStoppedAnimation(primaryGreen),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${comfortScore.round()}',
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: primaryGreen)),
                  Text(band.shortLabel,
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: primaryGreen)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(band.label,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF4C6FE0))),
              const SizedBox(height: 4),
              Text(band.description,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
