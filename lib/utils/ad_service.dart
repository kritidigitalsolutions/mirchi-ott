import 'package:easy_audience_network_plus/easy_audience_network.dart';
import 'package:flutter/foundation.dart';
import 'package:mirchi_ott/utils/constants.dart';

class AdService {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    
    await EasyAudienceNetwork.init(
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6", // Optional
      testMode: true,
    );
    _isInitialized = true;
    print("✅ Meta Audience Network Initialized (using Plus)");
  }

  // static void showInterstitialAd({VoidCallback? onComplete}) {
  //   if (kIsWeb || !_isInitialized) {
  //     onComplete?.call();
  //     return;
  //   }
  //
  //   bool adFinished = false;
  //
  //   final String placementId = AppConstants.metaInterstitialPlacementId == 'YOUR_PLACEMENT_ID'
  //       ? (defaultTargetPlatform == TargetPlatform.android
  //           ? "YOUR_ANDROID_PLACEMENT_ID"
  //           : "YOUR_IOS_PLACEMENT_ID")
  //       : AppConstants.metaInterstitialPlacementId;
  //
  //   final interstitialAd = InterstitialAd(placementId);
  //
  //   interstitialAd.listener = InterstitialAdListener(
  //     onLoaded: () {
  //       interstitialAd.show();
  //     },
  //     onDismissed: () {
  //       interstitialAd.destroy();
  //       if (!adFinished) {
  //         adFinished = true;
  //         onComplete?.call();
  //       }
  //     },
  //     onError: (code, message) {
  //       print("❌ Meta Ad Error: $code - $message");
  //       interstitialAd.destroy();
  //       if (!adFinished) {
  //         adFinished = true;
  //         onComplete?.call();
  //       }
  //     },
  //   );
  //
  //   interstitialAd.load();
  //
  //   // Fallback: If ad doesn't load within 5 seconds, continue
  //   Future.delayed(const Duration(seconds: 5), () {
  //     if (!adFinished) {
  //       adFinished = true;
  //       onComplete?.call();
  //     }
  //   });
  // }
}
