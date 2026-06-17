import 'package:flutter/material.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  bool isBannerLoaded = false;
  bool isInterstitialLoaded = false;
  bool isRewardedLoaded = false;
  BannerAd? bannerAd;

  void initialize() {}
  void loadBannerAd() {}
  void loadInterstitialAd() {}
  void showInterstitialAd() {}
  void loadRewardedAd() {}
  void showRewardedAd(Function onRewardEarned) {}
  void dispose() {}
}

class BannerAd {
  final String adUnitId;
  final dynamic size;
  final dynamic request;
  final dynamic listener;

  BannerAd({required this.adUnitId, required this.size, required this.request, required this.listener});
  void load() {}
  void dispose() {}
}

class AdSize {
  static final banner = AdSize();
  final int width = 320;
  final int height = 50;
}

class AdRequest {
  const AdRequest();
}

class BannerAdListener {
  final Function? onAdLoaded;
  final Function? onAdFailedToLoad;

  const BannerAdListener({this.onAdLoaded, this.onAdFailedToLoad});
}

class InterstitialAd {
  static void load({required String adUnitId, required dynamic request, required dynamic adLoadCallback}) {}
  void show() {}
  void dispose() {}
  dynamic fullScreenContentCallback;
}

class InterstitialAdLoadCallback {
  final Function onAdLoaded;
  final Function onAdFailedToLoad;

  const InterstitialAdLoadCallback({required this.onAdLoaded, required this.onAdFailedToLoad});
}

class RewardedAd {
  static void load({required String adUnitId, required dynamic request, required dynamic rewardedAdLoadCallback}) {}
  void show({required Function onUserEarnedReward}) {}
  void dispose() {}
  dynamic fullScreenContentCallback;
}

class RewardedAdLoadCallback {
  final Function onAdLoaded;
  final Function onAdFailedToLoad;

  const RewardedAdLoadCallback({required this.onAdLoaded, required this.onAdFailedToLoad});
}

class FullScreenContentCallback {
  final Function? onAdDismissedFullScreenContent;
  final Function? onAdFailedToShowFullScreenContent;

  const FullScreenContentCallback({this.onAdDismissedFullScreenContent, this.onAdFailedToShowFullScreenContent});
}

class AdWidget extends StatelessWidget {
  final dynamic ad;

  const AdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 50,
      color: Colors.grey[300],
      child: const Center(child: Text('Ad Placeholder', style: TextStyle(fontSize: 12))),
    );
  }
}

class AdWithoutView {}

class RewardItem {
  final int amount;
  final String type;

  RewardItem(this.amount, this.type);
}

class MobileAds {
  static final MobileAds instance = MobileAds._internal();
  factory MobileAds() => instance;
  MobileAds._internal();

  Future<void> initialize() async {}
}
