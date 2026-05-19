import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/theme/app_colors.dart';
import 'package:mirchi_ott/data/models/response_model/content_response_model/content_model.dart';
import '../dramaDetails/dramaDetailsPage.dart';
import 'package:mirchi_ott/view_model/content_controller/content_controller.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/notification_service.dart';
import '../auth/signInPage.dart';

class ComingSoonSection extends StatefulWidget {
  final List<ContentModel> content;
  final bool isSignedIn;
  final bool isFullPage;

  const ComingSoonSection({
    super.key,
    required this.content,
    required this.isSignedIn,
    this.isFullPage = false,
  });

  @override
  State<ComingSoonSection> createState() => _ComingSoonSectionState();
}

class _ComingSoonSectionState extends State<ComingSoonSection> {
  final box = GetStorage();

  bool _isReminded(String id) {
    return box.read('reminder_$id') ?? false;
  }

  void _toggleReminder(ContentModel item) {
    if (!widget.isSignedIn) {
      Get.to(() => const SignInPage());
      return;
    }

    bool current = _isReminded(item.id);
    box.write('reminder_${item.id}', !current);
    setState(() {});

    if (!current) {
      CustomSnackbar.show(
        title: "Reminder Set",
        message: "We will notify you on ${_formatDate(item.releaseDate)}",
      );
      // Schedule notification
      if (item.releaseDate != null) {
        try {
          DateTime releaseDate = DateTime.parse(item.releaseDate!);
          NotificationService.to.scheduleNotification(
            id: item.id.hashCode,
            title: "Coming Soon: ${item.title}",
            body: "${item.title} is now available to watch!",
            scheduledDate: releaseDate,
          );
        } catch (e) {
          print("Error scheduling notification: $e");
        }
      }
    } else {
      CustomSnackbar.show(
        title: "Reminder Removed",
        message: "Reminder for ${item.title} has been removed",
      );
      NotificationService.to.cancelNotification(item.id.hashCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ContentController contentController = Get.find<ContentController>();

    final displayContent = widget.isFullPage
        ? contentController.allContent.where((c) => c.isComingSoon == true).toList()
        : widget.content;

    if (displayContent.isEmpty && !widget.isFullPage) return const SizedBox.shrink();
    if (displayContent.isEmpty && widget.isFullPage) {
      return const Center(
          child: Text("No Upcoming Content", style: TextStyle(color: Colors.white)));
    }

    if (widget.isFullPage) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayContent.length,
        itemBuilder: (context, index) {
          final item = displayContent[index];
          return _buildUpcomingItem(item);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Coming Soon",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayContent.length,
            itemBuilder: (context, index) {
              final item = displayContent[index];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    if (!widget.isSignedIn) {
                      Get.to(() => const SignInPage());
                    } else {
                      Get.to(() =>
                          DramaDetailsPage(isSignedIn: widget.isSignedIn, content: item));
                    }
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          item.poster,
                          height: 250,
                          width: 170,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 250,
                            width: 170,
                            color: Colors.grey[900],
                            child: const Icon(Icons.broken_image,
                                color: Colors.white54, size: 40),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 250,
                              width: 170,
                              color: Colors.grey[900],
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _formatDate(item.releaseDate),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingItem(ContentModel item) {
    bool reminded = _isReminded(item.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (!widget.isSignedIn) {
                Get.to(() => const SignInPage());
              } else {
                Get.to(() => DramaDetailsPage(isSignedIn: widget.isSignedIn, content: item));
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                item.banner,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Releasing on: ${_formatDate(item.releaseDate)}",
                      style: const TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _toggleReminder(item),
                icon: Icon(
                  reminded ? Icons.notifications_active : Icons.notifications_none,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  reminded ? "Reminded" : "Remind Me",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: reminded ? Colors.red : Colors.grey[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Coming Soon";
    try {
      final date = DateTime.parse(dateStr);
      final months = ["Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
      return "${date.day} ${months[date.month - 1]}";
    } catch (e) {
      return "Coming Soon";
    }
  }
}
