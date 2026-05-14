import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/profile/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader("Notifications"),
          Obx(() => _buildSwitchTile(
                "Push Notifications",
                controller.isPushNotificationsEnabled.value,
                controller.togglePushNotifications,
              )),
          const SizedBox(height: 20),
          _buildSectionHeader("Playback"),
          Obx(() => _buildSwitchTile(
                "Auto Play",
                controller.isAutoPlayEnabled.value,
                controller.toggleAutoPlay,
              )),
          Obx(() => _buildSwitchTile(
                "WiFi Only",
                controller.isWiFiOnlyEnabled.value,
                controller.toggleWiFiOnly,
              )),
          const SizedBox(height: 20),
          _buildSectionHeader("Account"),
          _buildActionTile("Language", "English", () {}),
          _buildActionTile("App Version", "1.0.0", null),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.pinkAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildActionTile(String title, String trailing, VoidCallback? onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: Text(trailing, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    );
  }
}
