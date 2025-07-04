import 'package:date_spark_app/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final Logger _log = taggedLogger('AdManager');

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;

  AdManager._internal();

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  static const int maxFailedLoadAttempts = 3;

  void initializeAds() {
    MobileAds.instance.initialize();
    _createRewardedAd();
    _createInterstitialAd();
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3019314381670327/1602161553',
      request: AdRequest(
        nonPersonalizedAds: true,
      ),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          _log.info('Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _log.severe('Rewarded ad failed to load: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            _createRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem reward) onRewarded,
    required BuildContext context,
  }) {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Warning: RewardedAd not loaded yet.')),
      );
      _log.warning('Attempted to show rewarded ad before it was loaded');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          _log.info('Rewarded ad showed'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        _log.info('Rewarded ad dismissed');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        _log.severe('Rewarded ad failed to show: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        final fixedReward = RewardItem(1, reward.type);
        onRewarded(fixedReward);
      },
    );
    _rewardedAd = null;
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3019314381670327/7869493914',
      request: AdRequest(
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _log.info('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _log.severe('Interstitial ad failed to load: $error');
          _interstitialAd = null;
          _numInterstitialLoadAttempts += 1;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd({
    BuildContext? context,
    VoidCallback? onAdClosed,
  }) {
    if (_interstitialAd == null) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Warning: InterstitialAd not loaded yet.')),
        );
      }
      _log.warning('Attempted to show interstitial ad before it was loaded');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          _log.info('Interstitial ad showed'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _log.info('Interstitial ad dismissed');
        ad.dispose();
        _createInterstitialAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _log.severe('Interstitial ad failed to show: $error');
        ad.dispose();
        _createInterstitialAd();
        onAdClosed?.call();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  bool get isRewardedAdReady => _rewardedAd != null;
  bool get isInterstitialAdReady => _interstitialAd != null;

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
