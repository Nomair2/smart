import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/route_result.dart';
import '../widgets/alternative_route_row.dart';
import '../widgets/comfort_bar.dart';
import '../widgets/route_stat_chip.dart';
import 'route_details_page.dart';
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

  String _seasonWord(AppLocalizations l10n) {
    switch (result.seasonMode) {
      case SeasonMode.summer:
        return l10n.seasonWordSummer;
      case SeasonMode.winter:
        return l10n.seasonWordWinter;
      case SeasonMode.auto:
        return l10n.seasonWordToday;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final minutes = (result.estimatedTime.inSeconds / 60).round();

    return Scaffold(
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
                    Text(l10n.bestRouteFound,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(l10n.optimizedForComfort(_seasonWord(l10n)),
                        style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 15, color: Color(0xFFE0A83C)),
                                const SizedBox(width: 6),
                                Text(l10n.recommendedRoute,
                                    style: TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _EndpointRow(icon: Icons.door_front_door_rounded, label: l10n.fromLabel, name: result.origin.name ?? '—'),
                            const Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: SizedBox(
                                height: 16,
                                child: VerticalDivider(width: 2, thickness: 1.5, color: Color(0xFFDDE5E1)),
                              ),
                            ),
                            _EndpointRow(icon: Icons.location_city_rounded, label: l10n.toLabel, name: result.destination.name ?? '—'),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                RouteStatChip(
                                  icon: Icons.straighten_rounded,
                                  value: '${result.distanceMeters.round()} m',
                                  label: l10n.distanceLabel,
                                  color: const Color(0xFF4C6FE0),
                                  backgroundColor: const Color(0xFFEAEEFD),
                                ),
                                const SizedBox(width: 8),
                                RouteStatChip(
                                  icon: Icons.schedule_rounded,
                                  value: '$minutes min',
                                  label: l10n.estTimeLabel,
                                  color: const Color(0xFFB8860B),
                                  backgroundColor: const Color(0xFFFDF6E3),
                                ),
                                const SizedBox(width: 8),
                                RouteStatChip(
                                  icon: Icons.eco_rounded,
                                  value: '${result.comfortScore.round()}%',
                                  label: l10n.comfortLabel,
                                  color: primaryGreen,
                                  backgroundColor: const Color(0xFFEAF3EE),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(l10n.comfortAnalysis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                      const SizedBox(height: 8),
                      ComfortBar(
                        emoji: '\ud83c\udf3f',
                        label: l10n.shadeLabel,
                        value: result.shadePercent / 100,
                        trailing: '${result.shadePercent.round()}%',
                        color: primaryGreen,
                      ),
                      ComfortBar(
                        emoji: '\u2600\ufe0f',
                        label: l10n.sunLabel,
                        value: result.sunPercent / 100,
                        trailing: '${result.sunPercent.round()}%',
                        color: const Color(0xFFE0A83C),
                      ),
                      ComfortBar(
                        emoji: '\ud83d\udca8',
                        label: l10n.windLabel,
                        value: _windFill,
                        // result.windLabel is engine-computed domain data
                        // (Calm/Fair/Breezy/Strong), not UI copy — left
                        // untranslated, same as result.tip below and
                        // weather.condition elsewhere.
                        trailing: result.windLabel,
                        color: const Color(0xFF4C6FE0),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('\ud83d\udca1', style: TextStyle(fontSize: 15)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(result.tip,
                                  style: TextStyle(fontSize: 12.5, color: colorScheme.onPrimaryContainer, height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                      if (result.alternatives.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        Text(l10n.alternativeRoutes,
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
                              label: Text(l10n.viewRoute),
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => RouteDetailsPage(result: result)),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: const BorderSide(color: Color(0xFFDDE5E1)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(l10n.detailsLabel),
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
