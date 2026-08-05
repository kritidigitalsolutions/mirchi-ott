import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class FacebookEventsService {
  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  static void logEvent({required String name, Map<String, dynamic>? parameters}) {
    if (kIsWeb) return;
    _facebookAppEvents.logEvent(name: name, parameters: parameters);
    debugPrint("📊 Meta Event Logged: $name | Params: $parameters");
  }

  static void logLogin({String? method}) {
    if (kIsWeb) return;
    _facebookAppEvents.logEvent(
      name: "login",
      parameters: {
        "method": method ?? "unknown",
      },
    );
    debugPrint("📊 Meta Event: Login ($method)");
  }

  static void logRegistration({String? method}) {
    if (kIsWeb) return;
    _facebookAppEvents.logEvent(
      name: "fb_mobile_complete_registration",
      parameters: {
        "fb_registration_method": method ?? "unknown",
      },
    );
    debugPrint("📊 Meta Event: Registration ($method)");
  }

  static void logPurchase({required double amount, required String currency, String? contentId}) {
    if (kIsWeb) return;
    _facebookAppEvents.logPurchase(
      amount: amount,
      currency: currency,
      parameters: {
        "fb_content_id": contentId ?? "",
      },
    );
    debugPrint("📊 Meta Event: Purchase | Amount: $amount $currency");
  }

  static void logViewContent({required String id, required String type, required String title}) {
    if (kIsWeb) return;
    _facebookAppEvents.logViewContent(
      id: id,
      type: type,
      content: title,
    );
    debugPrint("📊 Meta Event: ViewContent | $title ($id)");
  }

  static void logSearch({required String query}) {
    if (kIsWeb) return;
    _facebookAppEvents.logEvent(
      name: "fb_mobile_search",
      parameters: {
        "fb_search_string": query,
      },
    );
    debugPrint("📊 Meta Event: Search | Query: $query");
  }
}
