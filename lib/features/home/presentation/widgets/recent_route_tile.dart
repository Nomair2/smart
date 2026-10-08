import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/recent_route_summary.dart';

class RecentRouteTile extends StatelessWidget {
  const RecentRouteTile({super.key, required this.route, this.onTap});

  final RecentRouteSummary route;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSummer = route.seasonMode == SeasonMode.summer;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Was hardcoded Colors.white / Color(0xFFEDF0EF) border.
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFEAF3EE), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.location_on_rounded, color: Color(0xFF1E5B3D), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${route.originName} \u2192 ${route.destinationName}',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${l10n.minWalkLabel(route.walkMinutes)} · ${_relativeTime(route.requestedAt, l10n)}',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSummer ? const Color(0xFFFDF6E3) : const Color(0xFFEAEEFD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isSummer ? l10n.summerBadge : l10n.winterBadge,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isSummer ? const Color(0xFFB8860B) : const Color(0xFF4C6FE0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime time, AppLocalizations l10n) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return l10n.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
    if (diff.inDays == 1) return l10n.yesterday;
    return l10n.timeAgoDays(diff.inDays);
  }
}
