import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/widget_service.dart';

/// Tela dedicada do WIDGET: explica e adiciona com 1 toque.
class WidgetScreen extends StatelessWidget {
  const WidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final tr = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.widgetScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(tr.widgetHeadline,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(tr.widgetSub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.4)),
          const SizedBox(height: 24),
          // Preview do widget
          Center(
            child: Container(
              width: 170,
              height: 170,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppTheme.gradient(s.theme.gradient),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.coupleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text('${s.daysTogether}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 46)),
                  Text(tr.widgetDaysTogether,
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(tr.widgetStyle,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: [
              _styleChip(context, s, 'full', tr.styleFull),
              const SizedBox(width: 8),
              _styleChip(context, s, 'minimal', tr.styleMinimal),
              const SizedBox(width: 8),
              _styleChip(context, s, 'heart', tr.styleHeart),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: s.theme.gradient.first,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => _add(context, s),
              icon: const Icon(Icons.add_to_home_screen_rounded),
              label: Text(tr.addToHome,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr.widgetManualTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(tr.widgetManualSteps,
                    style: const TextStyle(height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _styleChip(BuildContext context, AppState s, String id, String label) {
    final selected = s.widgetStyle == id;
    final accent = s.theme.gradient.first;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final st = context.read<AppState>();
          st.setWidgetStyle(id);
          WidgetService.update(st);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? accent : accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, AppState s) async {
    final tr = T.of(context);
    // Garante os dados atualizados antes de fixar.
    await WidgetService.update(s);
    final ok = await WidgetService.requestPin();
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr.widgetAddManual)));
    }
  }
}
