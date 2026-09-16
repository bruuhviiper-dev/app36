import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Compra única "Premium" (id `no_ads`): remove anúncios + libera tudo.
/// É ChangeNotifier para a loja atualizar o PREÇO REAL localizado da Play
/// assim que ele chega (moeda de cada país; o Google converte o preço único).
class PurchaseService extends ChangeNotifier {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  static const String premiumId = 'no_ads';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  void Function(String id)? _onEntitlement;
  ProductDetails? _premium;

  /// Preço REAL localizado da Play; fallback só até a loja responder.
  String get priceLabel => _premium?.price ?? 'R\$ 9,90';

  void onEntitlement(void Function(String id) cb) => _onEntitlement = cb;

  Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;
    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (_) {});
    final resp = await _iap.queryProductDetails({premiumId});
    if (resp.productDetails.isNotEmpty) {
      _premium = resp.productDetails.first;
      notifyListeners(); // avisa a loja para exibir o preço localizado
    }
    await _iap.restorePurchases();
  }

  Future<void> buyPremium() async {
    final p = _premium;
    if (p == null) return;
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));
  }

  Future<void> restore() => _iap.restorePurchases();

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _onEntitlement?.call(p.productID);
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
