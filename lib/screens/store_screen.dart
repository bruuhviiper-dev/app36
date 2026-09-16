import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/purchase_service.dart';

/// Loja: o Premium (compra única) remove anúncios + libera todos os temas.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  Future<void> _buy(BuildContext context, T tr) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(tr.processing)));
    await PurchaseService.instance.buyPremium();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final tr = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.storeTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.gradient(s.isPremium
                  ? const [Color(0xFF11998E), Color(0xFF38EF7D)]
                  : AppTheme.hero),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.isPremium ? '✅' : '💖',
                    style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(s.isPremium ? tr.youArePremium : tr.premiumHeadline,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(s.isPremium ? tr.premiumThanks : tr.premiumPitch,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.4)),
                if (!s.isPremium) ...[
                  const SizedBox(height: 12),
                  ...[
                    tr.perkNoAds,
                    tr.perkThemes,
                    tr.perkWidget,
                    tr.perkPhoto,
                  ].map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(t,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600)),
                      )),
                ],
                if (!s.isPremium) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    // Preço REAL da Play (moeda do país do usuário); atualiza
                    // quando a loja responde.
                    child: ListenableBuilder(
                      listenable: PurchaseService.instance,
                      builder: (context, _) => FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.brand,
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () => _buy(context, tr),
                        child: Text(
                            tr.buyPremium(PurchaseService.instance.priceLabel),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => PurchaseService.instance.restore(),
                      child: Text(tr.restore,
                          style: const TextStyle(color: Colors.white70)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _FreeBadge(),
        ],
      ),
    );
  }
}

class _FreeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tr = T.of(context);
    final items = [
      ('💞', tr.freeCounter),
      ('📅', tr.freeDates),
      ('🏠', tr.freeWidget),
      ('💌', tr.freeMessage),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.allFree,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: scheme.primary)),
          const SizedBox(height: 12),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Text(it.$1, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Text(it.$2,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
        ],
      ),
    );
  }
}
