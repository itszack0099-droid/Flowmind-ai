import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() =>
      _BannerAdWidgetState();
}

class _BannerAdWidgetState
    extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final width =
        MediaQuery.of(context).size.width
            .truncate();

    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (size == null) return;

    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-1579484168539674/3089120420'
          : 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx',

      size: size,

      request: const AdRequest(),

      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });

          debugPrint("Banner loaded");
        },

        onAdFailedToLoad:
            (ad, error) {
          ad.dispose();

          debugPrint(
              "Banner failed: $error");
        },
      ),
    );

    await _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded ||
        _bannerAd == null) {
      return const SizedBox();
    }

    return SafeArea(
      child: SizedBox(
        width: _bannerAd!.size.width
            .toDouble(),
        height: _bannerAd!.size.height
            .toDouble(),
        child: AdWidget(
          ad: _bannerAd!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}