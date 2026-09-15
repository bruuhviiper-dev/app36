import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';

/// Onboarding: nomes do casal + data de início do namoro.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  DateTime? _date;

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  bool get _valid =>
      _c1.text.trim().isNotEmpty && _c2.text.trim().isNotEmpty && _date != null;

  @override
  Widget build(BuildContext context) {
    final tr = T.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppTheme.hero,
        )),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            children: [
              const Center(child: Text('💞', style: TextStyle(fontSize: 64))),
              const SizedBox(height: 12),
              Text(tr.onbTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(tr.onbSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 30),
              _field(_c1, tr.yourName),
              const SizedBox(height: 14),
              _field(_c2, tr.partnerName),
              const SizedBox(height: 14),
              _dateField(context, tr),
              const SizedBox(height: 30),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.brand,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _valid
                    ? () {
                        context.read<AppState>().setup(
                            name1: _c1.text,
                            name2: _c2.text,
                            start: _date!);
                      }
                    : null,
                child: Text(tr.start,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _dateField(BuildContext context, T tr) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _date ?? DateTime(now.year - 1, now.month, now.day),
          firstDate: DateTime(1970),
          lastDate: now,
          helpText: tr.whenStarted,
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: AppTheme.brand),
            const SizedBox(width: 12),
            Text(
                _date == null
                    ? tr.startDateHint
                    : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}',
                style: TextStyle(
                    color: _date == null ? Colors.black54 : Colors.black87,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
