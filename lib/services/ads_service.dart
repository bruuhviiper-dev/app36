import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob: banner + premiado (rewarded). Nasce em TESTE; trocar os IDs reais e
/// `_useTestAds=false` na publicação. App ID vai no AndroidManifest.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const bool _useTestAds = false;

  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // IDs reais (Nosso Amor — preencher antes de publicar)
  static const _realBanner = 'ca-app-pub-5880219350817278/7641350082';
  static const _realRewarded = 'ca-app-pub-5880219350817278/4836444531';
  static bool _ph(String id) => id.contains('0000000000');

  bool _initialized = false;
  bool get _supported => Platform.isAndroid || Platform.isIOS;
  bool adsRemoved = false;

  String get bannerUnitId =>
      (_useTestAds || _ph(_realBanner)) ? _testBanner : _realBanner;
  String get _rewardedUnitId =>
      (_useTestAds || _ph(_realRewarded)) ? _testRewarded : _realRewarded;

  void init() {
    if (_initialized || !_supported) return;
    _initialized = true;
    MobileAds.instance.initialize();
  }

  /// Mostra o vídeo premiado; chama [onReward] se o usuário concluir.
  Future<bool> showRewarded(void Function() onReward) async {
    if (!_supported) {
      onReward();
      return true;
    }
    final completer = Completer<bool>();
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          var earned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(earned);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(false);
            },
          );
          ad.show(onUserEarnedReward: (ad, reward) {
            earned = true;
            onReward();
          });
        },
        onAdFailedToLoad: (err) {
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  }
}
