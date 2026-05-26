import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirchi_ott/utils/app_images.dart';
import 'package:mirchi_ott/view_model/auth_controller/auth_controller.dart';
import 'package:mirchi_ott/view_model/download_controller/download_controller.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/app_colors.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../view_model/content_controller/content_controller.dart';
import '../../view_model/like_dislike_controller/like_dislike_controller.dart';
import '../../view_model/watchlist_controller/watchlist_controller.dart';
import '../auth/signInPage.dart';
import '../popUp/age_popup.dart';
import '../videoPlayer/video_player.dart';
import 'cast_crewPage.dart';
import '../premium/goPremium.dart';
import '../../utils/share_service.dart';
import '../../view_model/drama_detail_controller/drama_details_controller.dart';
import '../../utils/custom_snackbar.dart';

class DramaDetailsPage extends StatefulWidget {
  final bool isSignedIn;
  final ContentModel content;

  const DramaDetailsPage({super.key, required this.isSignedIn, required this.content});

  @override
  State<DramaDetailsPage> createState() => _DramaDetailsPageState();
}

class _DramaDetailsPageState extends State<DramaDetailsPage> {
  final DramaDetailsController controller = Get.put(DramaDetailsController());
  final AuthController authController = Get.find<AuthController>();
  final WatchlistController watchlistController = Get.put(WatchlistController());
  final ContentController contentController = Get.find<ContentController>();
  final PremiumController premiumController = Get.put(PremiumController());
  final InteractionController interactionController = Get.put(InteractionController());
  final DownloadController downloadController = Get.put(DownloadController());

  @override
  void initState() {
    super.initState();
    if (widget.content.contentType == 'series') {
      contentController.fetchEpisodes(widget.content.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter "You May Also Like"
    final List<ContentModel> relatedContent = contentController.allContent.where((item) {
      return item.id != widget.content.id && 
             item.contentType == widget.content.contentType && 
             item.category.any((cat) => widget.content.category.contains(cat));
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 Banner Section
            Stack(
              children: [
                Image.network(
                  widget.content.banner,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    AppImages.farzi,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                if (widget.content.trailerUrl != null && widget.content.trailerUrl!.isNotEmpty)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      final bool? isOver18 = await Get.dialog<bool>(const AgeRestrictionPopup());
                      if (isOver18 == true) {
                        Get.to(() => AdvancedVideoPlayer(
                          url: widget.content.trailerUrl!, 
                          title: '${widget.content.title} - Trailer'
                        ));
                      }
                    },
                    icon: const Icon(Icons.play_arrow, color: AppColors.white),
                    label: const Text("Watch Trailer", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.content.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("${widget.content.releaseYear} • ${widget.content.language} ${widget.content.duration != null ? '• ${widget.content.duration}' : ''}", style: const TextStyle(color: AppColors.white, fontSize: 14)),
            ),

            const SizedBox(height: 20),

            /// 🔐 DYNAMIC WATCH BUTTON (For Movies or General Series Play)
            if (widget.content.contentType != 'series') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final sub = premiumController.subscriptionData.value;
                  final bool isPurchased =
                      sub != null && sub['status'] == 'active';
                  final bool userLoggedIn = authController.isLoggedIn.value;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: widget.content.isComingSoon 
                      ? null 
                      : () {
                        if (!userLoggedIn) {
                          Get.to(() => const SignInPage());
                        } else if (isPurchased || !widget.content.isPremium) {
                          if (widget.content.videoUrl != null &&
                              widget.content.videoUrl!.isNotEmpty) {
                            Get.to(() => AdvancedVideoPlayer(
                                url: widget.content.videoUrl!,
                                title: widget.content.title));
                          } else {
                            CustomSnackbar.show(
                                title: "Error",
                                message: "Video URL not found",
                                isError: true);
                          }
                        } else {
                          Get.to(() => const GoPremiumPage());
                        }
                      },
                    child: Text(
                      widget.content.isComingSoon 
                        ? "Coming soon on ${_formatReleaseDate(widget.content.releaseDate)}"
                        : "Watch Video",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              /// ⬇ DYNAMIC DOWNLOAD BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final sub = premiumController.subscriptionData.value;
                  final bool isPurchased =
                      sub != null && sub['status'] == 'active';
                  final bool userLoggedIn = authController.isLoggedIn.value;
                  final bool isAlreadyDownloaded =
                      downloadController.isDownloaded(widget.content.id);
                  final bool downloading =
                      downloadController.isDownloading[widget.content.id] ??
                          false;

                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        minimumSize: const Size(double.infinity, 50)),
                    onPressed: () {
                      if (!userLoggedIn) {
                        Get.to(() => const SignInPage());
                      } else if (isPurchased) {
                        if (isAlreadyDownloaded) {
                          CustomSnackbar.show(
                              title: "Info", message: "Already downloaded");
                        } else {
                          downloadController.downloadVideo(widget.content);
                        }
                      } else {
                        _showSubscriptionDialog(context);
                      }
                    },
                    child: downloading
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  value: downloadController
                                          .downloadProgress[widget.content.id] ??
                                      0,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${((downloadController.downloadProgress[widget.content.id] ?? 0) * 100).toInt()}%",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          )
                        : isAlreadyDownloaded
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text("Downloaded",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              )
                            : const Text("Download",
                                style: TextStyle(color: Colors.white)),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.content.description, style: const TextStyle(color: Colors.white70)),
            ),

            const SizedBox(height: 20),

            /// ⭐ Action Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: watchlistController.isLoading.value
                            ? null
                            : () => watchlistController.toggleWatchlist(widget.content.id.toString()),
                        child: Icon(
                          watchlistController.isInWatchlist(widget.content.id.toString())
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Watchlist", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),

                  _actionButton(
                    icon: interactionController.isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: "Like",
                    onTap: () => interactionController.toggleLike(contentId: widget.content.id, contentType: widget.content.contentType),
                  ),

                  _actionButton(
                    icon: interactionController.isDisliked.value ? Icons.thumb_down : Icons.thumb_down_outlined,
                    label: "Dislike",
                    onTap: () => interactionController.toggleDislike(contentId: widget.content.id, contentType: widget.content.contentType),
                  ),

                  _actionButton(
                    icon: Icons.share,
                    label: "Share",
                    onTap: () {
                      ShareService.shareContent(
                        title: widget.content.title,
                        imageUrl: widget.content.poster,
                      );
                    },
                  ),
                ],
              )),
            ),

            const SizedBox(height: 25),

            /// 📺 EPISODES SECTION FOR SERIES
            if (widget.content.contentType == 'series') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      "Seasons",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.content.totalSeasons ?? 1,
                          itemBuilder: (context, index) {
                            final seasonNum = index + 1;
                            return Obx(() => GestureDetector(
                              onTap: () => controller.selectedSeason.value = seasonNum,
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: controller.selectedSeason.value == seasonNum 
                                      ? AppColors.buttonColor 
                                      : Colors.grey[900],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Season $seasonNum",
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (contentController.isEpisodesLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
                }

                final episodes = contentController.seriesEpisodes.where((item) => 
                  item.seasonNumber == controller.selectedSeason.value
                ).toList();

                if (episodes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("No episodes found for this season.", style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final episode = episodes[index];
                    return ListTile(
                      onTap: () {
                        final userLoggedIn = authController.isLoggedIn.value;
                        final sub = premiumController.subscriptionData.value;
                        final bool isPurchased = sub != null && sub['status'] == 'active';

                        if (!userLoggedIn) {
                          Get.to(() => const SignInPage());
                        } else if (isPurchased || !episode.isPremium) {
                          if (episode.videoUrl != null && episode.videoUrl!.isNotEmpty) {
                            Get.to(() => AdvancedVideoPlayer(url: episode.videoUrl!, title: episode.title));
                          } else {
                            CustomSnackbar.show(title: "Error", message: "Video URL not found", isError: true);
                          }
                        } else {
                          Get.to(() => const GoPremiumPage());
                        }
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          episode.poster,
                          width: 100,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(AppImages.farzi, width: 100, height: 60, fit: BoxFit.cover),
                        ),
                      ),
                      title: Text(episode.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      subtitle: Text(episode.duration ?? "", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: const Icon(Icons.play_circle_outline, color: Colors.white),
                    );
                  },
                );
              }),
            ],

            const SizedBox(height: 25),

            /// 🎭 Cast & Crew
            if (widget.content.cast != null && widget.content.cast!.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Cast & Crew", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.content.cast!.length,
                  itemBuilder: (context, index) {
                    final actor = widget.content.cast![index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => CastDetailsPage(castName: actor.name, castImage: actor.image));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: (actor.image.isNotEmpty) 
                                    ? NetworkImage(actor.image) 
                                    : AssetImage(AppImages.farzi) as ImageProvider,
                                  fit: BoxFit.cover,
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

            const SizedBox(height: 25),

            /// ❤️ You May Also Like
            if (relatedContent.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("You May Also Like", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedContent.length,
                  itemBuilder: (context, index) {
                    final item = relatedContent[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => DramaDetailsPage(isSignedIn: authController.isLoggedIn.value, content: item), preventDuplicates: false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.poster,
                            width: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset(AppImages.asur, width: 110, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _formatReleaseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Soon";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "Soon";
    }
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Subscription Required", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("You need a subscription to download this video.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white), onPressed: () => Get.back(), child: const Text("Cancel"))),
                  const SizedBox(width: 15),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor), onPressed: () { Get.back(); Get.to(() => const GoPremiumPage()); }, child: const Text("Explore Plan", style: TextStyle(color: Colors.white)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
