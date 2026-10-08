import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

/// Stand-in landing screen for admins (report section 3.3.2-B: account
/// management, campus endpoints, path segments, availability, monitoring).
/// Swap this out once the real admin dashboard is built.
class AdminHomePlaceholderPage extends StatelessWidget {
  const AdminHomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = fb.FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminTitleSuffix)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.admin_panel_settings_rounded,
              size: 40,
              color: Color(0xFF1E5B3D),
            ),
            const SizedBox(height: 12),
            Text(l10n.signedInAsAdmin(user?.email ?? l10n.unknownEmail)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => fb.FirebaseAuth.instance.signOut(),
              child: Text(l10n.signOutForAdmin),
            ),
          ],
        ),
      ),
    );
  }
}
