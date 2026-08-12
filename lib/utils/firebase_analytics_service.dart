import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static void logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    _analytics.logEvent(name: name, parameters: parameters);
    debugPrint("🔥 Firebase Event Logged: $name | Params: $parameters");
  }

  static void logLogin({required String method}) {
    _analytics.logLogin(loginMethod: method);
    debugPrint("🔥 Firebase Event: Login ($method)");
  }

  static void logRegistration({required String method}) {
    _analytics.logSignUp(signUpMethod: method);
    debugPrint("🔥 Firebase Event: Registration ($method)");
  }

  static void logPurchase({
    required double amount,
    required String currency,
    String? contentId,
  }) {
    _analytics.logPurchase(
      value: amount,
      currency: currency,
      items: [AnalyticsEventItem(itemId: contentId, itemName: "Premium Plan")],
    );
    debugPrint("🔥 Firebase Event: Purchase | Amount: $amount $currency");
  }

  static void logAppOpen() {
    _analytics.logAppOpen();
    debugPrint("🔥 Firebase Event: App Open");
  }

  static void logViewContent({
    required String id,
    required String type,
    required String title,
  }) {
    _analytics.logSelectContent(contentType: type, itemId: id);
    debugPrint("🔥 Firebase Event: ViewContent | $title ($id)");
  }

  static void logSearch({required String query}) {
    _analytics.logSearch(searchTerm: query);
    debugPrint("🔥 Firebase Event: Search | Query: $query");
  }

  static void logInitiateCheckout({
    required double amount,
    required String currency,
    String? contentId,
  }) {
    _analytics.logBeginCheckout(
      value: amount,
      currency: currency,
      items: [AnalyticsEventItem(itemId: contentId, itemName: "Premium Plan")],
    );
    debugPrint(
      "🔥 Firebase Event: Initiate Checkout | Amount: $amount $currency",
    );
  }
}
