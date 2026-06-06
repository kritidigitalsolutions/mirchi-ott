import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import 'package:mirchi_ott/widgets/custom_network_image.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../view_model/home_controller/home_controller.dart';
import '../../view_model/watchlist_controller/watchlist_controller.dart';
import '../dramaDetails/dramaDetailsPage.dart';
import '../homePages/mainHomepage.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final WatchlistController controller = Get.put(WatchlistController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: const Text(
          "Watchlist",
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: Obx(() {
        /// 🔄 LOADING
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        /// ❌ EMPTY STATE
        if (controller.watchlist.isEmpty) {
          return _emptyState();
        }

        /// ✅ LIST
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: controller.watchlist.length,
          itemBuilder: (context, index) {
            final item = controller.watchlist[index];
            final watchlistId = item['_id'] ?? '';
            final contentData = item['item'];

            // UI variables
            String title = "Unknown Title";
            String poster = "";
            String year = "";
            ContentModel? contentItem;

            if (contentData != null && contentData is Map<String, dynamic>) {
              // Copy data and inject itemModel as 'type' if missing
              final Map<String, dynamic> fullData = Map<String, dynamic>.from(contentData);
              if (fullData['type'] == null && item['itemModel'] != null) {
                fullData['type'] = item['itemModel'].toString().toLowerCase();
              }
              
              contentItem = ContentModel.fromJson(fullData);
              title = contentItem.title;
              poster = contentItem.poster;
              year = contentItem.releaseYear.toString();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  if (contentItem != null) {
                    Get.to(() => DramaDetailsPage(
                          isSignedIn: authController.isLoggedIn.value,
                          content: contentItem!,
                        ));
                  }
                },
                leading: poster.isNotEmpty
                    ? CustomNetworkImage(
                        imageUrl: poster,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        borderRadius: 8,
                      )
                    : const Icon(Icons.movie, color: Colors.white, size: 50),
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  year != "0" ? "Year: $year" : "Watchlist Item",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    controller.removeFromWatchlist(watchlistId);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// 🔥 EMPTY UI
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade700, width: 2),
              ),
              child: const Icon(Icons.bookmark_border, size: 50, color: AppColors.white),
            ),
            const SizedBox(height: 30),
            const Text(
              "No Watchlist Added Yet",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Adding to Watchlist is a great way to make sure you always have something to watch.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final homeController = Get.find<HomeController>();
                  homeController.selectedIndex.value = 1;
                  Get.offAll(() => const MainHomePage());
                },
                child: const Text(
                  ""
                      "Start Adding",
                  style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
