class AppConstants {
  static const String baseUrl = 'http://192.168.1.19:5000/api';

  // Auth Endpoints
  static const String sendOtp = '$baseUrl/user/auth/send-otp';
  static const String verifyOtp = '$baseUrl/user/auth/verify-otp';
  /// user proflie
  static const String getProfile = '$baseUrl/user/profile';
  static const String createProfile = '$baseUrl/user/profile-info';

  /// fcm
  static const String updateFcmToken = '$baseUrl/user/fcm-token';

  /// notifications
  static const String getNotifications = '$baseUrl/notifications';
  static String markNotificationRead(String id) => '$baseUrl/notifications/$id/read';
  static const String markAllNotificationsRead = '$baseUrl/notifications/read-all';
  static String deleteNotification(String id) => '$baseUrl/notifications/$id';

  /// legal
  static const String privacyPolicyUrl = '$baseUrl/user/legal/privacy-policy';
  static const String termsAndConditionsUrl = '$baseUrl/user/legal/terms-conditions';
  static const String refundPolicy = '$baseUrl/user/legal/refund-policy';
  static const String helpSupport = '$baseUrl/help';

  /// content
  static const String getAllContent = '$baseUrl/content';

  /// payment
  static const String createOrder = '$baseUrl/payment/create-order';
  static const String verifyPayment = '$baseUrl/payment/verify';

  /// watchlist
  static const String addWatchlist = '$baseUrl/user/watchlist';
  static const String getWatchlist = '$baseUrl/user/watchlist';
  static const String removeWatchlist = '$baseUrl/user/watchlist';

  /// interaction
  static const String toggleInteraction = '$baseUrl/interaction/toggle';
  static const String interactionStats = '$baseUrl/interaction/stats';

  /// review
  static const String rateApp = '$baseUrl/rating/rate';
  /// plans
  static const String planList = '$baseUrl/plans';
  static const String buyPlan = '$baseUrl/subscription/subscribe';
  static const String planCheck = '$baseUrl/subscription/status';
  static const String cancelPlan = '$baseUrl/subscription/status';

  /// voucher
  static const String redeemVoucher = '$baseUrl/voucher/redeem';
}
