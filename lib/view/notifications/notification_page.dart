import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import '../../utils/notification_service.dart';
import '../../app/theme/app_colors.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService.to;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        actions: [
          Obx(() => notificationService.notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  onPressed: () {
                    _showClearAllDialog(context, notificationService);
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notificationService.fetchNotifications(),
        color: AppColors.buttonColor,
        child: Obx(() {
          if (notificationService.isLoading.value &&
              notificationService.notifications.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.buttonColor));
          }

          if (notificationService.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: notificationService.notifications.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              final notification = notificationService.notifications[index];
              return _buildNotificationItem(context, notification, index, notificationService);
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 100, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            "No notifications yet",
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notification,
      int index, NotificationService service) {
    final DateTime time = DateTime.parse(notification['time']);
    final String formattedTime = DateFormat('dd MMM, hh:mm a').format(time);
    final bool isRead = notification['isRead'] ?? false;

    return GestureDetector(
      onTap: () {
        service.markAsRead(index);
        _showNotificationDetail(context, notification, index, service);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: isRead
              ? null
              : Border.all(color: AppColors.buttonColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isRead ? Colors.grey.withOpacity(0.2) : AppColors.buttonColor,
              child: const Icon(Icons.notifications, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] ?? 'Notification',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showDeleteDialog(context, index, service);
                        },
                        child: Icon(Icons.close, size: 18, color: Colors.white.withOpacity(0.4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['body'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedTime,
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(BuildContext context, Map<String, dynamic> notification,
      int index, NotificationService service) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notification Detail",
                  style: TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              notification['title'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              notification['body'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Get.back(),
                child: const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, NotificationService service) {
    Get.defaultDialog(
      title: "Clear All",
      middleText: "Are you sure you want to clear all notifications?",
      backgroundColor: Colors.grey[900],
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "Clear",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.buttonColor,
      onConfirm: () {
        service.clearNotifications();
        Get.back();
      },
    );
  }
  void _showDeleteDialog(BuildContext context, int index, NotificationService service) {
    Get.defaultDialog(
      title: "Delete Notification",
      middleText: "Are you sure you want to delete this notification?",
      backgroundColor: Colors.grey[900],
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),

      // ❌ Remove this
      // textCancel: "Cancel",

      // ✅ Custom Cancel Button
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey[700], // change background color
        ),
        child: const Text(
          "Cancel",
          style: TextStyle(
            color: Colors.white, // change text color
          ),
        ),
      ),

      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.buttonColor,

      onConfirm: () {
        service.deleteSingleNotification(index);
        Get.back();
      },
    );
  }
}
