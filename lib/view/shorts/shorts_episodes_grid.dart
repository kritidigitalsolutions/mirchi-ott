import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/routes/app_routes.dart';
import 'package:mirchi_ott/app/theme/app_colors.dart';
import 'package:mirchi_ott/data/models/shorts_model.dart';
import 'package:mirchi_ott/view/shorts/vertical_shorts_player.dart';
import 'package:mirchi_ott/view_model/shorts_controller/shorts_controller.dart';
import 'package:mirchi_ott/view_model/auth_controller/auth_controller.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import 'package:mirchi_ott/widgets/custom_network_image.dart';

class ShortsEpisodesGrid extends StatelessWidget {
  final ShortDrama drama;
  const ShortsEpisodesGrid({super.key, required this.drama});

  @override
  Widget build(BuildContext context) {
    final ShortsController controller = Get.find<ShortsController>();
    final AuthController authController = Get.find<AuthController>();
    final PremiumController premiumController = Get.find<PremiumController>();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(drama.title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: FutureBuilder<List<ShortEpisode>>(
        future: controller.fetchEpisodes(drama.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No episodes found", style: TextStyle(color: Colors.white)));
          }

          final episodes = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              
              // Lock logic
              bool isLocked = true;
              final bool loggedIn = authController.isLoggedIn.value;
              if (loggedIn) {
                final sub = premiumController.subscriptionData.value;
                final bool hasActivePlan = sub != null && sub['status'] == 'active';
                if (episode.episodeNumber == 1 || hasActivePlan) {
                  isLocked = false;
                }
              }

              return GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.shortsPlayer, arguments: {
                    'episodes': episodes,
                    'initialIndex': index,
                    'dramaName': drama.title,
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomNetworkImage(
                            imageUrl: episode.thumbnail,
                            fit: BoxFit.cover,
                            borderRadius: 8,
                          ),
                          Container(
                            color: isLocked ? Colors.black45 : Colors.transparent,
                          ),
                            Center(
                              child: Icon(
                                isLocked ? Icons.lock : Icons.play_circle_outline,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      episode.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
