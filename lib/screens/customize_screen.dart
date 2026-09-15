import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import '../services/ads_service.dart';
import '../services/app_state.dart';
import '../services/widget_service.dart';
import 'store_screen.dart';

/// Personalizar: foto do casal, tema de cores e modo escuro.
class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final tr = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.customizeTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Perfil do casal (nomes + data)
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: Text(tr.namesAndDate),
            subtitle: Text('${s.coupleLabel} • ${tr.startedOn(_fmtStart(s))}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _editProfile(context, s, tr),
          ),
          const Divider(height: 1),
          // Foto do casal
          ListTile(
            leading: const Icon(Icons.photo_camera_rounded),
            title: Text(tr.couplePhoto),
            subtitle: Text(s.photoPath.isEmpty ? tr.addPhoto : tr.changePhoto),
            trailing: s.photoPath.isNotEmpty && File(s.photoPath).existsSync()
                ? CircleAvatar(backgroundImage: FileImage(File(s.photoPath)))
                : const Icon(Icons.chevron_right_rounded),
            onTap: () => _pickPhoto(context),
          ),
          SwitchListTile(
            secondary: Icon(
                s.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            title: Text(tr.darkMode),
            value: s.isDark,
            onChanged: (_) => context.read<AppState>().toggleDark(),
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Text('🎨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(tr.coupleTheme,
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              for (final t in CoupleTheme.all)
                _ThemeTile(
                  theme: t,
                  selected: s.themeId == t.id,
                  locked: t.premium && !s.hasThemeAccess,
                  onTap: () {
                    if (!t.premium || s.hasThemeAccess) {
                      final st = context.read<AppState>();
                      st.setTheme(t.id);
                      WidgetService.update(st);
                    } else {
                      _unlock(context, t.id);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!s.hasThemeAccess)
            _unlockCta(context, tr)
          else if (s.hasTemporaryPro && !s.isPremium)
            Text(tr.themesUnlockedTemp,
                style: TextStyle(color: s.theme.gradient.last)),
        ],
      ),
    );
  }

  static String _fmtStart(AppState s) {
    final d = s.startDate;
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _editProfile(BuildContext context, AppState s, T tr) async {
    final c1 = TextEditingController(text: s.name1);
    final c2 = TextEditingController(text: s.name2);
    DateTime date = s.startDate ?? DateTime.now();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text(tr.ourProfile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c1,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: tr.yourName),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: c2,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: tr.partnerName),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final p = await showDatePicker(
                    context: ctx,
                    initialDate: date,
                    firstDate: DateTime(1970),
                    lastDate: DateTime.now(),
                  );
                  if (p != null) setInner(() => date = p);
                },
                icon: const Icon(Icons.favorite_rounded, size: 18),
                label: Text(
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(tr.cancel)),
            FilledButton(
              onPressed: () {
                final st = context.read<AppState>();
                st.setup(name1: c1.text, name2: c2.text, start: date);
                WidgetService.update(st);
                Navigator.pop(ctx);
              },
              child: Text(tr.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 88);
    if (x != null && context.mounted) {
      final st = context.read<AppState>();
      st.setPhoto(x.path);
      WidgetService.update(st);
    }
  }

  Widget _unlockCta(BuildContext context, T tr) {
    final accent = context.read<AppState>().theme.gradient.last;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: AppTheme.gradient(
              [accent, accent.withValues(alpha: 0.7)]),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.unlockThemesTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(tr.unlockThemesBody,
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: accent),
                onPressed: () => _watch(context, tr),
                child: Text(tr.video24h),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70)),
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StoreScreen())),
                child: Text(tr.premium),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _unlock(BuildContext context, String themeId) {
    final tr = T.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr.premiumTheme,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.play_circle_fill_rounded,
                  color: Color(0xFFE84393), size: 30),
              title: Text(tr.watchVideo24h),
              onTap: () {
                Navigator.pop(ctx);
                _watch(context, tr, then: themeId);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.workspace_premium_rounded,
                  color: Color(0xFFD9A406), size: 30),
              title: Text(tr.premiumForever),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StoreScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _watch(BuildContext context, T tr, {String? then}) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(tr.loadingVideo)));
    final ok = await AdsService.instance.showRewarded(() {
      context.read<AppState>().grantTemporaryPro(const Duration(hours: 24));
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (ok && then != null) context.read<AppState>().setTheme(then);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr.videoUnavailable)));
    }
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile(
      {required this.theme,
      required this.selected,
      required this.locked,
      required this.onTap});
  final CoupleTheme theme;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradient(theme.gradient),
                    borderRadius: BorderRadius.circular(16),
                    border: selected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                ),
                if (locked)
                  const Positioned.fill(
                    child: Center(
                        child: Icon(Icons.lock_rounded, color: Colors.white)),
                  ),
                if (selected)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.check_rounded,
                            size: 14, color: Colors.black87)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(T.of(context).themeName(theme.id),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
        ],
      ),
    );
  }
}
