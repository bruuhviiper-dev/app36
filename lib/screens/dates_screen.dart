import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/app_theme.dart';
import '../data/couple_date.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../widgets/banner_ad.dart';

/// Datas importantes: aniversário de namoro, próximos marcos e datas do casal.
class DatesScreen extends StatelessWidget {
  const DatesScreen({super.key});

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  static String _countdown(T tr, int days) {
    if (days == 0) return tr.isToday;
    if (days == 1) return tr.tomorrow;
    return tr.daysLeft(days);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final tr = T.of(context);
    final start = s.startDate;
    final accent = s.theme.gradient.last;

    // Aniversário de namoro (recorrente).
    final aniv = start == null
        ? null
        : CoupleDate('aniv', tr.datingAnniversary, start, emoji: '💞');

    // Próximos marcos (100/200/300/500/1000 dias e 1..5 anos).
    final marcos = <_M>[];
    if (start != null) {
      final days = s.daysTogether;
      for (final m in [100, 200, 300, 500, 1000, 2000]) {
        if (m > days) {
          marcos.add(_M(tr.daysTogetherN(m), m - days, '🎯'));
        }
      }
      for (var y = 1; y <= 10; y++) {
        final target = DateTime(start.year + y, start.month, start.day);
        final d = target.difference(DateTime.now()).inDays;
        if (d >= 0 && d <= 400) marcos.add(_M(tr.yearsTogether(y), d, '🎂'));
      }
      marcos.sort((a, b) => a.days.compareTo(b.days));
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr.datesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        onPressed: () => _addDialog(context, tr),
        icon: const Icon(Icons.add_rounded),
        label: Text(tr.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          if (aniv != null) ...[
            _header(tr.anniversary),
            _tile(context, aniv.emoji, aniv.name,
                '${tr.everyOn} ${_fmt(aniv.date)}',
                _countdown(tr, aniv.daysUntilNext()), accent, big: true),
          ],
          if (marcos.isNotEmpty) ...[
            _header(tr.nextMilestones),
            for (final m in marcos.take(4))
              _tile(context, m.emoji, m.name, '', _countdown(tr, m.days), accent),
          ],
          const MediumRectangleAd(),
          _header(tr.ourDates),
          if (s.dates.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(tr.datesEmpty,
                  style: const TextStyle(color: Colors.grey)),
            ),
          for (final d in s.dates)
            Dismissible(
              key: ValueKey(d.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                final st = context.read<AppState>();
                st.removeDate(d.id);
                NotificationService.instance.reschedule(st);
              },
              child: _tile(context, d.emoji, d.name,
                  '${tr.everyOn} ${_fmt(d.date)}',
                  _countdown(tr, d.daysUntilNext()), accent),
            ),
          if (s.countdowns.isNotEmpty) ...[
            _header(tr.countdownSection),
            for (final c in s.countdowns)
              Dismissible(
                key: ValueKey(c.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  final st = context.read<AppState>();
                  st.removeDate(c.id);
                  NotificationService.instance.reschedule(st);
                },
                child: _countdownCard(context, c, accent),
              ),
          ],
        ],
      ),
    );
  }

  Widget _countdownCard(BuildContext context, CoupleDate c, Color accent) {
    final tr = T.of(context);
    final days = c.daysUntilNext();
    final big = days < 0 ? '💕' : '$days';
    final label = days < 0
        ? tr.alreadyHappened
        : days == 0
            ? tr.todayShort
            : days == 1
                ? tr.oneDayLeft
                : tr.daysRemaining;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.gradient([accent, accent.withValues(alpha: 0.65)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(c.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
                Text('${_fmt(c.date)}/${c.date.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              ],
            ),
          ),
          Column(
            children: [
              Text(big,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      height: 1.0)),
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(t,
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w800)),
      );

  Widget _tile(BuildContext context, String emoji, String name, String sub,
      String countdown, Color accent,
      {bool big = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: big
            ? AppTheme.gradient([accent, accent.withValues(alpha: 0.7)])
            : null,
        color: big
            ? null
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: big ? Colors.white : null)),
                if (sub.isNotEmpty)
                  Text(sub,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: big ? Colors.white70 : Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: big
                  ? Colors.white.withValues(alpha: 0.25)
                  : accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(countdown,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: big ? Colors.white : accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _addDialog(BuildContext context, T tr) async {
    final nameC = TextEditingController();
    DateTime? date;
    String emoji = '💗';
    bool recurring = true;
    const emojis = ['💗', '💋', '💍', '👰', '🎂', '🏠', '✈️', '⭐'];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text(tr.newDate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: tr.dateNameHint),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: [
                  for (final e in emojis)
                    GestureDetector(
                      onTap: () => setInner(() => emoji = e),
                      child: CircleAvatar(
                        backgroundColor: emoji == e
                            ? Theme.of(ctx).colorScheme.primaryContainer
                            : Colors.transparent,
                        child: Text(e, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                      value: true,
                      label: Text(tr.everyYear),
                      icon: const Icon(Icons.repeat_rounded, size: 16)),
                  ButtonSegment(
                      value: false,
                      label: Text(tr.countdown),
                      icon: const Icon(Icons.hourglass_bottom_rounded, size: 16)),
                ],
                selected: {recurring},
                onSelectionChanged: (s) => setInner(() {
                  recurring = s.first;
                  date = null;
                }),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final p = await showDatePicker(
                    context: ctx,
                    initialDate: recurring ? now : now.add(const Duration(days: 1)),
                    firstDate: recurring ? DateTime(1970) : now,
                    lastDate: DateTime(now.year + 30),
                  );
                  if (p != null) setInner(() => date = p);
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Text(date == null
                    ? (recurring ? tr.chooseDate : tr.eventDate)
                    : '${_fmt(date!)}/${date!.year}'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(tr.cancel)),
            FilledButton(
              onPressed: (nameC.text.trim().isEmpty || date == null)
                  ? null
                  : () {
                      final st = context.read<AppState>();
                      st.addDate(nameC.text, date!,
                          emoji: emoji, recurring: recurring);
                      NotificationService.instance.reschedule(st);
                      Navigator.pop(ctx);
                    },
              child: Text(tr.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _M {
  _M(this.name, this.days, this.emoji);
  final String name;
  final int days;
  final String emoji;
}
