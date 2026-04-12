import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;

  bool isBannerLoaded = false;
  bool isInterstitialLoaded = false;
  bool isRewardedLoaded = false;

  final String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  final String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  final String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  void initialize() {
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          isBannerLoaded = false;
          ad.dispose();
        },
      ),
    )..load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialLoaded = true;
          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isInterstitialLoaded = false;
              loadInterstitialAd(); // Load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              isInterstitialLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          isInterstitialLoaded = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (isInterstitialLoaded && interstitialAd != null) {
      interstitialAd!.show();
    }
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedLoaded = true;
          rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isRewardedLoaded = false;
              loadRewardedAd(); // Load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              isRewardedLoaded = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          isRewardedLoaded = false;
        },
      ),
    );
  }

  void showRewardedAd(Function onRewardEarned) {
    if (isRewardedLoaded && rewardedAd != null) {
      rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem maxReward) {
          onRewardEarned();
        },
      );
    }
  }

  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
  }
}
