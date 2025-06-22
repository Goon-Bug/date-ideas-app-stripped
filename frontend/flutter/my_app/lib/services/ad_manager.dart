import 'dart:developer';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

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
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313',
      request: AdRequest(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
      ),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          log('Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Rewarded ad failed to load: $error');
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
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => log('Rewarded ad showed'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        log('Rewarded ad dismissed');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        log('Rewarded ad failed to show: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onRewarded(reward);
      },
    );
    _rewardedAd = null;
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910',
      request: AdRequest(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          log('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Interstitial ad failed to load: $error');
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
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('Interstitial ad showed'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('Interstitial ad dismissed');
        ad.dispose();
        _createInterstitialAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('Interstitial ad failed to show: $error');
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
