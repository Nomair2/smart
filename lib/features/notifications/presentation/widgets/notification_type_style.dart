import 'package:flutter/material.dart';

import '../../domain/entities/notification_item.dart';

/// Icon/color/label for a [NotificationType] — same small-classifier
/// pattern as `maneuverStyle` in the routing feature, so both screens style
/// their "kind of thing" badges the same way.
class NotificationTypeStyle {
  const NotificationTypeStyle({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String label;
}

NotificationTypeStyle notificationTypeStyle(NotificationType type) {
  switch (type) {
    case NotificationType.weatherAlert:
      return const NotificationTypeStyle(
        icon: Icons.wb_sunny_rounded,
        color: Color(0xFFE0574C),
        backgroundColor: Color(0xFFFDEBEA),
        label: 'Weather',
      );
    case NotificationType.routeUpdate:
      return const NotificationTypeStyle(
        icon: Icons.alt_route_rounded,
        color: Color(0xFF4C6FE0),
        backgroundColor: Color(0xFFEAEEFD),
        label: 'Route',
      );
    case NotificationType.maintenance:
      return const NotificationTypeStyle(
        icon: Icons.build_rounded,
        color: Color(0xFFB8860B),
        backgroundColor: Color(0xFFFDF6E3),
        label: 'Maintenance',
      );
    case NotificationType.system:
      return const NotificationTypeStyle(
        icon: Icons.info_rounded,
        color: Color(0xFF1E5B3D),
        backgroundColor: Color(0xFFEAF3EE),
        label: 'System',
      );
  }
}
