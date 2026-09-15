import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_theme.dart';
import '../data/couple_questions.dart';
import '../data/love_messages.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';

/// Home: o contador de dias juntos + mensagem de amor do dia.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Atualiza o "há X" a cada minuto (para virar o dia sozinho).
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = s.theme;
    final tr = T.of(context);
    final (y, m, d) = s.ymd;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient(t.gradient)),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              // Topo: nome centralizado + ícone de compartilhar (só o contador).
              Row(
                children: [
                  const SizedBox(width: 44),
                  Expanded(
                    child: Text(s.coupleLabel,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            shadows: const [
                              Shadow(color: Colors.black26, blurRadius: 6)
                            ])),
                  ),
                  IconButton(
                    tooltip: tr.shareCounter,
                    onPressed: () => _share(s, tr),
                    icon: const Icon(Icons.ios_share_rounded,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _photo(s),
              const SizedBox(height: 12),
              Text(tr.togetherFor,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 15)),
              Text('${s.daysTogether}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 76,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(color: Colors.black38, blurRadius: 12)
                      ])),
              Text(tr.day(s.daysTogether),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(tr.orYmd(y, m, d),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13.5)),
              const SizedBox(height: 12),
              _milestone(s.daysTogether, tr),
              const SizedBox(height: 12),
              _messageAndQuestion(tr),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photo(AppState s) {
    const size = 124.0;
    final hasPhoto = s.photoPath.isNotEmpty && File(s.photoPath).existsSync();
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.22),
          border: Border.all(color: Colors.white, width: 3),
          image: hasPhoto
              ? DecorationImage(
                  image: FileImage(File(s.photoPath)), fit: BoxFit.cover)
              : null,
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 6))
          ],
        ),
        child: hasPhoto
            ? null
            : const Center(child: Text('💑', style: TextStyle(fontSize: 64))),
      ),
    );
  }

  static const _milestones = [
    30, 60, 100, 180, 200, 300, 365, 500, 730, 1000, 1500, 2000, 3000, 3650
  ];

  Widget _milestone(int days, T tr) {
    final isMilestone = _milestones.contains(days);
    int? next;
    for (final m in _milestones) {
      if (m > days) {
        next = m;
        break;
      }
    }
    final text = isMilestone
        ? tr.milestoneToday(days)
        : next == null
            ? tr.milestoneEvery
            : tr.milestoneNext(next - days, next);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isMilestone ? 0.30 : 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700)),
    );
  }

  void _share(AppState s, T tr) {
    Share.share(tr.shareText(
        s.coupleLabel, s.daysTogether, LoveMessages.ofDay(tr.l)));
  }

  /// Mensagem + pergunta do dia num card único e compacto (cabe sem rolar).
  Widget _messageAndQuestion(T tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _cardRow('💌', tr.messageOfDay, LoveMessages.ofDay(tr.l)),
          Divider(color: Colors.white.withValues(alpha: 0.22), height: 20),
          _cardRow('💬', tr.questionOfDay, CoupleQuestions.ofDay(tr.l),
              hint: tr.answerTogether),
        ],
      ),
    );
  }

  Widget _cardRow(String emoji, String title, String body, {String? hint}) {
    return Column(
      children: [
        Text('$emoji $title',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 5),
        Text(body,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.3,
                fontWeight: FontWeight.w500)),
        if (hint != null) ...[
          const SizedBox(height: 3),
          Text(hint,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ],
    );
  }
}
