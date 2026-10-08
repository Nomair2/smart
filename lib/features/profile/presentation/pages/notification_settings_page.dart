import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/section_label.dart';
import '../widgets/settings_tile.dart';

/// Reached from the "Notification Settings" tile. There's no push-
/// notification delivery (FCM) feature built yet — the original TODO
/// said as much — so these switches don't turn real alerts on or off
/// today. What they DO: persist the user's intent locally, under keys
/// a future notifications feature can read directly, so the toggle
/// isn't thrown away just because it's early. No new repository or
/// Firestore collection, in line with the scope of "a suitable screen".
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  static const Color primaryGreen = Color(0xFF1E5B3D);

  static const _routeRemindersKey = 'notif_route_reminders';
  static const _weatherAlertsKey = 'notif_weather_alerts';
  static const _announcementsKey = 'notif_announcements';

  bool _loaded = false;
  bool _routeReminders = true;
  bool _weatherAlerts = true;
  bool _announcements = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _routeReminders = prefs.getBool(_routeRemindersKey) ?? true;
      _weatherAlerts = prefs.getBool(_weatherAlertsKey) ?? true;
      _announcements = prefs.getBool(_announcementsKey) ?? true;
      _loaded = true;
    });
  }

  Future<void> _set(String key, bool value, void Function(bool) apply) async {
    setState(() => apply(value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold/AppBar colors come from AppTheme now (light/dark) instead
    // of being hardcoded here — see core/theme/app_theme.dart.
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  const SectionLabel('Alerts & Reminders'),
                  SettingsTile(
                    icon: Icons.directions_walk_rounded,
                    iconColor: primaryGreen,
                    iconBg: const Color(0xFFEAF3EE),
                    title: 'Route Reminders',
                    subtitle: 'Nudges to head out in time for your next class',
                    trailing: Switch(
                      value: _routeReminders,
                      activeColor: primaryGreen,
                      onChanged: (v) => _set(_routeRemindersKey, v, (val) => _routeReminders = val),
                    ),
                    onTap: () =>
                        _set(_routeRemindersKey, !_routeReminders, (val) => _routeReminders = val),
                  ),
                  SettingsTile(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: const Color(0xFFE0A83C),
                    iconBg: const Color(0xFFFDF6E3),
                    title: 'Weather & Season Alerts',
                    subtitle: 'When Auto mode switches between Summer/Winter',
                    trailing: Switch(
                      value: _weatherAlerts,
                      activeColor: primaryGreen,
                      onChanged: (v) => _set(_weatherAlertsKey, v, (val) => _weatherAlerts = val),
                    ),
                    onTap: () => _set(_weatherAlertsKey, !_weatherAlerts, (val) => _weatherAlerts = val),
                  ),
                  SettingsTile(
                    icon: Icons.campaign_outlined,
                    iconColor: const Color(0xFF7B4CE0),
                    iconBg: const Color(0xFFF1EAFD),
                    title: 'App Announcements',
                    subtitle: 'New features & campus updates',
                    trailing: Switch(
                      value: _announcements,
                      activeColor: primaryGreen,
                      onChanged: (v) => _set(_announcementsKey, v, (val) => _announcements = val),
                    ),
                    onTap: () => _set(_announcementsKey, !_announcements, (val) => _announcements = val),
                  ),
                ],
              ),
            ),
    );
  }
}
