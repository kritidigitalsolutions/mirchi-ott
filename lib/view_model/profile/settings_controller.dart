import 'package:get/get.dart';

class SettingsController extends GetxController {
  var isPushNotificationsEnabled = true.obs;
  var isAutoPlayEnabled = true.obs;
  var isWiFiOnlyEnabled = false.obs;

  void togglePushNotifications(bool value) => isPushNotificationsEnabled.value = value;
  void toggleAutoPlay(bool value) => isAutoPlayEnabled.value = value;
  void toggleWiFiOnly(bool value) => isWiFiOnlyEnabled.value = value;
}
