import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  static RewardedAd? _rewardedAd;

  static bool isLoaded = false;

  static void loadAd() {
    RewardedAd.load(
      adUnitId:
          'ca-app-pub-1579484168539674/2111122237',
      request: const AdRequest(),

      rewardedAdLoadCallback:
          RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isLoaded = true;

          print("Rewarded Ad Loaded");
        },

        onAdFailedToLoad: (error) {
          isLoaded = false;

          print(
              "Rewarded Ad failed: $error");
        },
      ),
    );
  }

  static void showAd(
      VoidCallback onRewardEarned) {
    if (_rewardedAd == null) {
      print("Ad not ready");

      loadAd();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward:
          (ad, reward) {
        onRewardEarned();
      },
    );

    _rewardedAd = null;
    isLoaded = false;

    loadAd();
  }
}