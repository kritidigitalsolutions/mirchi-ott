import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/theme/app_colors.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import 'package:mirchi_ott/view_model/download_controller/download_controller.dart';
import 'package:mirchi_ott/widgets/custom_network_image.dart';
import '../../app/routes/app_routes.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../view_model/home_controller/home_controller.dart';
import '../auth/signInPage.dart';
import '../dramaDetails/dramaDetailsPage.dart';
import '../videoPlayer/video_player.dart';
import '../../utils/custom_snackbar.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final HomeController homeController = Get.find<HomeController>();
    final DownloadController downloadController = Get.put(DownloadController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: const Text(
          "Downloads",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Obx(() {
        /// 🔐 NOT LOGGED IN
        if (!authController.isLoggedIn.value) {
          return _baseEmptyView(
            title: "Please sign in to view your downloads",
            buttonText: "Sign In",
            onTap: () => Get.toNamed(AppRoutes.signIn),
          );
        }

        /// 📭 EMPTY DOWNLOADS
        if (downloadController.downloadedContent.isEmpty) {
          return _baseEmptyView(
            title: "No downloads yet",
            buttonText: "Explore",
            onTap: () {
              Get.back(); // Back to Profile
              homeController.selectedIndex.value = 1; // Switch to Home Tab
            },
          );
        }

        /// 📥 DOWNLOAD LIST
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: downloadController.downloadedContent.length,
          itemBuilder: (context, index) {
            final item = downloadController.downloadedContent[index];
            final localPath = downloadController.getLocalPath(item.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),

                /// 🎬 OPEN DETAILS PAGE
                onTap: () {
                  Get.toNamed(AppRoutes.dramaDetails, arguments: item);
                },

                /// 🎞 POSTER
                leading: CustomNetworkImage(
                  imageUrl: item.poster,
                  width: 55,
                  height: 75,
                  fit: BoxFit.cover,
                  borderRadius: 8,
                ),

                /// 📄 TITLE + DETAILS
                title: Text(
                  item.contentType == 'episode' ? "${item.title}" : item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  item.contentType == 'episode' 
                    ? "S${item.seasonNumber} E${item.episodeNumber} • ${item.duration ?? ''}"
                    : "${item.releaseYear} • ${item.language}",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                /// 🎯 ACTION BUTTONS
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ▶ PLAY OFFLINE
                    IconButton(
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.green,
                        size: 28,
                      ),
                      onPressed: () {
                        if (localPath != null && File(localPath).existsSync()) {
                          Get.toNamed(AppRoutes.videoPlayer, arguments: {
                            'url': localPath,
                            'title': item.title,
                          });
                        } else {
                          CustomSnackbar.show(
                            title: "Error",
                            message: "File not found. Please download again.",
                            isError: true,
                          );
                        }
                      },
                    ),

                    /// 🗑 DELETE
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: const Text("Delete Download", style: TextStyle(color: Colors.white)),
                            content: const Text("Are you sure you want to delete this download?", style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                onPressed: () {
                                  Get.back(); // Close dialog first
                                  downloadController.removeDownload(item.id);
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// 🔄 EMPTY / LOGIN VIEW
  Widget _baseEmptyView({
    required String title,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.download_for_offline_outlined,
              size: 90,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Download your favourite movies and shows to watch offline anytime.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onTap,
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
