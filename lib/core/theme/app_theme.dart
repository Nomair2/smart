import 'package:flutter/material.dart';

/// Light/dark themes for the whole app, seeded from the brand green used
/// throughout (Select Route, Profile, etc.) so Material defaults —
/// buttons, switches, radios, progress indicators, text fields — pick
/// the right color automatically instead of every screen hardcoding it.
///
/// Scope note: only the Profile feature's screens have been switched
/// over to read these tokens so far (`ProfilePage`, `AppSettingsPage`,
/// `HelpSupportPage`, `NotificationSettingsPage`). Other features
/// (home, routing, auth, notifications/alerts) still hardcode their own
/// light-mode colors directly and will look unchanged — neither broken
/// nor dark-mode-aware — until each is migrated the same way: drop the
/// explicit `backgroundColor`/`foregroundColor` overrides on `Scaffold`/
/// `AppBar` and let them inherit from here.
class AppTheme {
  AppTheme._();

  static const Color primaryGreen = Color(0xFF1E5B3D);

  static const Color _lightScaffold = Color(0xFFF6F8F7);
  static const Color _darkScaffold = Color(0xFF121714);
  static const Color _darkSurfaceHigh = Color(0xFF1B2420);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryGreen,
      surface: _lightScaffold,
      // Reused as the "muted card on the scaffold" color (e.g. the
      // University Email box on the profile page) — kept identical to
      // the scaffold color here to preserve the app's existing light
      // look exactly; dark mode gives it real contrast instead (below).
      surfaceContainerHighest: _lightScaffold,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightScaffold,
      // The "white rounded card over a tinted/gradient header" pattern
      // (auth pages, route details, etc.) wants a surface distinct from
      // both the scaffold and from colorScheme.surface (which is pinned
      // to match the scaffold above, for the Profile feature's flatter
      // look) — cardColor is that third, dedicated token.
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightScaffold,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
    ).copyWith(
      // A lighter tint of the brand green — the base primaryGreen is too
      // close to the dark background for good contrast/legibility.
      primary: const Color(0xFF4CAF7D),
      surface: _darkScaffold,
      surfaceContainerHighest: _darkSurfaceHigh,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkScaffold,
      cardColor: _darkSurfaceHigh,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkScaffold,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
