import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/theme/app_colors.dart';
import 'package:mirchi_ott/data/models/response_model/content_response_model/content_model.dart';
import 'package:mirchi_ott/widgets/custom_network_image.dart';
import '../dramaDetails/dramaDetailsPage.dart';
import 'package:mirchi_ott/view_model/content_controller/content_controller.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/notification_service.dart';
import '../../utils/responsive.dart';
import '../auth/signInPage.dart';

class ComingSoonSection extends StatefulWidget {
  final List<ContentModel> content;
  final bool isSignedIn;
  final bool isFullPage;

  const ComingSoonSection({
    super.key, required this.content, required this.isSignedIn, this.isFullPage = false,
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
    bool isDesktop = Responsive.isDesktop(context);

    return Obx(() {
      final displayContent = widget.isFullPage
          ? contentController.allContent.where((c) => c.isComingSoon == true).toList()
          : widget.content;

      if (displayContent.isEmpty && !widget.isFullPage) return const SizedBox.shrink();
      if (displayContent.isEmpty && widget.isFullPage) {
        if (contentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return const Center(
            child: Text("No Upcoming Content", style: TextStyle(color: Colors.white)));
      }

      if (widget.isFullPage) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: displayContent.length,
              itemBuilder: (context, index) {
                final item = displayContent[index];
                return _buildUpcomingItem(item, isDesktop);
              },
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Coming Soon",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: isDesktop ? 300 : 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayContent.length,
              itemBuilder: (context, index) {
                final item = displayContent[index];
                return Container(
                  width: isDesktop ? 200 : 170,
                  margin: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Get.to(() => DramaDetailsPage(isSignedIn: widget.isSignedIn, content: item));
                    },
                    child: Stack(
                      children: [
                        CustomNetworkImage(
                          imageUrl: item.poster,
                          height: isDesktop ? 300 : 250,
                          width: isDesktop ? 200 : 170,
                          fit: BoxFit.cover,
                          borderRadius: 15,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _formatDate(item.releaseDate),
                                style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
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
    });
  }

  Widget _buildUpcomingItem(ContentModel item, bool isDesktop) {
    bool reminded = _isReminded(item.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => DramaDetailsPage(isSignedIn: widget.isSignedIn, content: item));
            },
            child: CustomNetworkImage(
              imageUrl: item.banner,
              height: isDesktop ? 400 : 220,
              width: double.infinity,
              fit: BoxFit.cover,
              customBorderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(color: Colors.white, fontSize: isDesktop ? 24 : 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Releasing on: ${_formatDate(item.releaseDate)}",
                        style: const TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _toggleReminder(item),
                  icon: Icon(
                    reminded ? Icons.notifications_active : Icons.notifications_none,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    reminded ? "Reminded" : "Remind Me",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: reminded ? Colors.red : AppColors.buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
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
