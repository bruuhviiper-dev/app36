import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_info.dart';
import '../data/app_theme.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';
import 'store_screen.dart';
import 'widget_screen.dart';

/// Aba "Mais": Premium, widget, avaliar, compartilhar e cross-promo Phantom.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _grads = [
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    [Color(0xFFE84393), Color(0xFFFD79A8)],
    [Color(0xFF2563EB), Color(0xFF3B82F6)],
    [Color(0xFFFF4B2B), Color(0xFFC9184A)],
    [Color(0xFF6C4BF4), Color(0xFF8E54E9)],
  ];
  static const _emojis = ['🔮', '❤️', '📅', '🔥', '💬'];

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apps = AppInfo.otherApps;
    final tr = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.moreTitle)),
      body: ListView(
        children: [
          Consumer<AppState>(
            builder: (c, s, _) => s.isPremium
                ? const SizedBox.shrink()
                : ListTile(
                    leading:
                        const Icon(Icons.favorite_rounded, color: AppTheme.brand),
                    title: Text(tr.premiumTitle),
                    subtitle: Text(tr.premiumSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StoreScreen())),
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.add_to_home_screen_rounded,
                color: Color(0xFF00B894)),
            title: Text(tr.widgetTile),
            subtitle: Text(tr.widgetTileSub),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WidgetScreen())),
          ),
          Consumer<AppState>(
            builder: (c, s, _) => SwitchListTile(
              secondary: const Icon(Icons.notifications_active_rounded,
                  color: Color(0xFFE17055)),
              title: Text(tr.remindersTile),
              subtitle: Text(tr.remindersSub),
              value: s.reminderOn,
              onChanged: (v) async {
                final st = context.read<AppState>();
                st.setReminder(on: v);
                if (v) {
                  await NotificationService.instance.reschedule(st);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr.remindersOn)));
                  }
                } else {
                  await NotificationService.instance.cancelAll();
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star_rounded, color: Color(0xFFFBBF24)),
            title: Text(tr.rateApp),
            subtitle: Text(tr.rateSub),
            onTap: () => _open(AppInfo.playUrl),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share_rounded),
            title: Text(tr.shareApp),
            onTap: () => Share.share(tr.shareAppText(AppInfo.playUrl)),
          ),
          // Cross-promo: só em português (os outros apps da Phantom são PT).
          if (tr.l == 'pt') ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
              child: Row(children: [
                const Text('✨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(tr.moreApps,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900)),
              ]),
            ),
            for (int i = 0; i < apps.length; i++)
              _PromoCard(
                title: apps[i].$1,
                emoji: _emojis[i % _emojis.length],
                gradient: _grads[i % _grads.length],
                label: tr.openApp,
                onTap: () => _open(AppInfo.playUrlFor(apps[i].$2)),
              ),
          ],
          const SizedBox(height: 16),
          Center(
              child: Text('${tr.byDeveloper} ${AppInfo.developer}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard(
      {required this.title,
      required this.emoji,
      required this.gradient,
      required this.label,
      required this.onTap});
  final String title;
  final String emoji;
  final List<Color> gradient;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.gradient(gradient),
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(label,
                      style: TextStyle(
                          color: gradient.last,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
