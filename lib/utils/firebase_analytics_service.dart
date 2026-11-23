import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseAnalyticsService {
  static FirebaseAnalytics get _analytics {
    try {
      // Check if Firebase is initialized before accessing instance
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAnalytics.instance;
      }
    } catch (e) {
      debugPrint("⚠️ Firebase Analytics not initialized: $e");
    }
    // Return a dummy or handle the case where it's not ready
    // For simplicity, we just check before every call now.
    throw Exception("Firebase not initialized");
  }

  static bool get _isReady => Firebase.apps.isNotEmpty;

  static void logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    if (!_isReady) return;
    FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
    debugPrint("🔥 Firebase Event Logged: $name | Params: $parameters");
  }

  static void logLogin({required String method}) {
    if (!_isReady) return;
    FirebaseAnalytics.instance.logLogin(loginMethod: method);
    debugPrint("🔥 Firebase Event: Login ($method)");
  }

  static void logRegistration({required String method}) {
    if (!_isReady) return;
    FirebaseAnalytics.instance.logSignUp(signUpMethod: method);
    debugPrint("🔥 Firebase Event: Registration ($method)");
  }

  static void logPurchase({
    required double amount,
    required String currency,
    String? contentId,
  }) {
    if (!_isReady) return;
    FirebaseAnalytics.instance.logPurchase(
      value: amount,
      currency: currency,
      items: [AnalyticsEventItem(itemId: contentId, itemName: "Premium Plan")],
    );
    debugPrint("🔥 Firebase Event: Purchase | Amount: $amount $currency");
  }

  static void logAppOpen() {
    if (!_isReady) return;
    FirebaseAnalytics.instance.logAppOpen();
    debugPrint("🔥 Firebase Event: App Open");
  }

  static void logViewContent({
    required String id,
    required String type,
    required String title,
  }) {
    if (!_isReady) return;
    FirebaseAnalytics.instance.logSelectContent(contentType: type, itemId: id);
    debugPrint("🔥 Firebase Event: ViewContent | $title ($id)");
  }

  static void logSearch({required String query}) {
    if (!_isReady) return;
    FirebaseAnalytics.instance.logSearch(searchTerm: query);
    debugPrint("🔥 Firebase Event: Search | Query: $query");
  }

  static void logInitiateCheckout({
    required double amount,
    required String currency,
    String? contentId,
  }) {
    if (!_isReady) return;
    FirebaseAnalytics.instance.logBeginCheckout(
      value: amount,
      currency: currency,
      items: [AnalyticsEventItem(itemId: contentId, itemName: "Premium Plan")],
    );
    debugPrint(
      "🔥 Firebase Event: Initiate Checkout | Amount: $amount $currency",
    );
  }
}
