import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/section_label.dart';
import '../widgets/settings_tile.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const Color primaryGreen = Color(0xFF1E5B3D);

  // TODO: point these at your real support channels.
  static const String supportEmail = 'support@smartpath.app';
  static const String supportPhone = '+966500000000';

  static const List<_FaqEntry> _faqs = [
    _FaqEntry(
      question: 'How does "Find Best Route" pick a path?',
      answer:
          'It runs a Multi-Constraint A* search over the campus paths, '
          'balancing raw distance against shade/sun exposure. Which one '
          'matters more depends on your "Optimize For" choice: Shortest '
          'weighs distance only, Comfort weighs shade heavily, and Balanced '
          'splits the two.',
    ),
    _FaqEntry(
      question: "What's the difference between Summer, Winter, and Auto?",
      answer:
          'Summer favors shaded paths, Winter favors sun-exposed or '
          'sheltered paths, and Auto checks the current temperature and '
          'picks whichever profile fits — no need to switch manually as the '
          'weather changes.',
    ),
    _FaqEntry(
      question: "A building or gate is missing from the destination list",
      answer:
          "Only active, mapped locations show up as a starting point or "
          "destination. If somewhere you need isn't listed yet, send us a "
          "message below and we'll get it added.",
    ),
    // _FaqEntry(
    //   question: 'How do I save a route for later?',
    //   answer:
    //       'From a route\'s results screen, tap the save icon — it shows '
    //       'up under "My Saved Routes" on your profile, and the count there '
    //       'updates too.',
    // ),
    _FaqEntry(
      question: 'Is my university email or location shared with anyone?',
      answer:
          "Your profile data stays tied to your account and is only "
          "used to personalize your routes and stats — it isn't shared "
          "with other students or outside the app.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold/AppBar colors come from AppTheme now (light/dark) instead
    // of being hardcoded here — see core/theme/app_theme.dart.
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const SectionLabel('Frequently Asked Questions'),
            ..._faqs.map((faq) => _FaqTile(entry: faq)),
            const SectionLabel('Contact Us'),
            SettingsTile(
              icon: Icons.mail_outline_rounded,
              iconColor: const Color(0xFF4C6FE0),
              iconBg: const Color(0xFFEAEEFD),
              title: 'Send us a message',
              subtitle: supportEmail,
              onTap: () => _openMessageSheet(context),
            ),
            SettingsTile(
              icon: Icons.phone_outlined,
              iconColor: primaryGreen,
              iconBg: const Color(0xFFEAF3EE),
              title: 'Call / WhatsApp',
              subtitle: supportPhone,
              onTap: () => _launchPhone(supportPhone),
            ),
            SettingsTile(
              icon: Icons.bug_report_outlined,
              iconColor: const Color(0xFFE0574C),
              iconBg: const Color(0xFFFDEBEA),
              title: 'Report a problem',
              subtitle: 'Send a description of what happened',
              onTap: () => _launchEmail(
                subject: 'Smart Path — Problem report',
                body:
                    'Describe what happened and what you expected instead:\n\n',
              ),
            ),
            const SectionLabel('About'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'Smart Path • v1.0.0',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail({required String subject, String body = ''}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    await launchUrl(uri);
  }

  Future<void> _launchPhone(String phone) async {
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  void _openMessageSheet(BuildContext context) {
    final messageController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Send us a message',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'This opens your email app addressed to $supportEmail.',
                style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'What do you need help with?',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _launchEmail(
                    subject: 'Smart Path — Support request',
                    body: messageController.text.trim(),
                  );
                },
                child: const Text('Send'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FaqEntry {
  const _FaqEntry({required this.question, required this.answer});
  final String question;
  final String answer;
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.entry});
  final _FaqEntry entry;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.entry.question,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8, right: 28),
                child: Text(
                  widget.entry.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }
}
