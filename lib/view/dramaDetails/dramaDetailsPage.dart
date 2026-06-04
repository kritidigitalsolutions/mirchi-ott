import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirchi_ott/utils/app_images.dart';
import 'package:mirchi_ott/utils/responsive.dart';
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
    interactionController.fetchStatus(widget.content.id);
    if (authController.isLoggedIn.value && watchlistController.watchlist.isEmpty) {
      watchlistController.getWatchlist();
    }
    if (widget.content.contentType == 'series') {
      contentController.fetchEpisodes(widget.content.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Responsive.isDesktop(context);
    final List<ContentModel> relatedContent = contentController.allContent.where((item) {
      return item.id != widget.content.id &&
             item.contentType == widget.content.contentType &&
             item.category.any((cat) => widget.content.category.contains(cat));
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
          child: Responsive.backButton(context, onPressed: () => Navigator.maybePop(context)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🎬 CINEMATIC HERO SECTION
            _buildHeroSection(isDesktop),

            /// 📖 CONTENT AREA
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      /// WATCH & DOWNLOAD BUTTONS (Moved here from Banner)
                      if (widget.content.contentType != 'series') ...[
                        Row(
                          children: [
                            Expanded(child: _buildWatchButton(isDesktop: isDesktop)),
                            if (!kIsWeb) ...[
                              const SizedBox(width: 15),
                              Expanded(child: _buildMainDownloadButton(isDesktop: isDesktop)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 25),
                      ],

                      /// DESCRIPTION & INFO (Mobile Only or additional)
                      if (!isDesktop) ...[
                        Text(widget.content.description, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                        const SizedBox(height: 20),
                        _buildSmallActionsRow(),
                        const SizedBox(height: 20),
                      ],

                      /// 📺 SEASONS & EPISODES
                      if (widget.content.contentType == 'series')
                        _buildEpisodesSection(context, isDesktop),

                      const SizedBox(height: 50),

                      /// 🎭 CAST & CREW
                      if (widget.content.cast != null && widget.content.cast!.isNotEmpty)
                        _buildCastSection(isDesktop),

                      const SizedBox(height: 50),

                      /// ❤️ MORE LIKE THIS
                      if (relatedContent.isNotEmpty)
                        _buildRelatedSection(relatedContent, isDesktop),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      height: isDesktop ? 750 : 350,
      color: Colors.black,
      child: Stack(
        children: [
          /// THE ACTUAL BANNER (Full image shown)
          Center(
            child: Image.network(
              widget.content.banner,
              width: double.infinity,
              height: isDesktop ? 750 : 350,
              fit: BoxFit.contain, // Shows full banner without zooming
              errorBuilder: (context, error, stackTrace) => Image.asset(
                AppImages.farzi,
                width: double.infinity,
                height: isDesktop ? 750 : 350,
                fit: BoxFit.contain,
              ),
            ),
          ),
          /// SUBTLE GRADIENT OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black,
                ],
                stops: const [0.7, 0.9, 1.0],
              ),
            ),
          ),

          /// INFO OVERLAY
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.content.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 42 : 24,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 10,
                          offset: const Offset(2, 2))
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "${widget.content.releaseYear} • ${widget.content.language}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 16 : 13,
                          fontWeight: FontWeight.bold),
                    ),
                    if (widget.content.duration != null) ...[
                      const SizedBox(width: 15),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(widget.content.duration!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                if (isDesktop)
                  SizedBox(
                    width: 700,
                    child: Text(
                      widget.content.description,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 5),

                /// TRAILER & SMALL ACTIONS (Watch Now removed from here)
                Row(
                  children: [
                    if (isDesktop) 
                      _buildSmallActionsRow(),
                  ],
                ),
              ],
            ),
          ),

          /// TRAILER BUTTON AT BOTTOM RIGHT
          if (widget.content.trailerUrl != null && widget.content.trailerUrl!.isNotEmpty)
            Positioned(
              bottom: 30,
              right: isDesktop ? 60 : 20,
              child: _buildTrailerButton(isDesktop: isDesktop),
            ),
        ],
      ),
    );
  }

  Widget _buildMainDownloadButton({required bool isDesktop}) {
    return Obx(() {
      final bool userLoggedIn = authController.isLoggedIn.value;
      final bool isAlreadyDownloaded = downloadController.isDownloaded(widget.content.id);
      final bool downloading = downloadController.isDownloading[widget.content.id] ?? false;

      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2),
          padding: EdgeInsets.symmetric(vertical: isDesktop ? 22 : 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          if (!userLoggedIn) {
            Get.to(() => const SignInPage());
          } else if (isAlreadyDownloaded) {
            CustomSnackbar.show(title: "Info", message: "Already downloaded");
          } else {
            downloadController.downloadVideo(widget.content);
          }
        },
        icon: downloading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(isAlreadyDownloaded ? Icons.check_circle : Icons.download_for_offline, color: Colors.white),
        label: Text(
          downloading ? "DOWNLOADING..." : (isAlreadyDownloaded ? "DOWNLOADED" : "DOWNLOAD"),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    });
  }

  Widget _buildWatchButton({required bool isDesktop}) {
    return Obx(() {
      final sub = premiumController.subscriptionData.value;
      final bool isPurchased = sub != null && sub['status'] == 'active';
      final bool userLoggedIn = authController.isLoggedIn.value;

      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          padding: EdgeInsets.symmetric(vertical: isDesktop ? 22 : 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 10,
        ),
        onPressed: widget.content.isComingSoon ? null : () => _handlePlay(widget.content, isPurchased, userLoggedIn),
        icon: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
        label: Text(
          widget.content.isComingSoon ? "COMING SOON" : "WATCH NOW",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      );
    });
  }

  void _handlePlay(dynamic item, bool isPurchased, bool userLoggedIn) {
    if (!userLoggedIn) {
      Get.to(() => const SignInPage());
    } else if (isPurchased || !item.isPremium) {
      if (item.videoUrl != null && item.videoUrl!.isNotEmpty) {
        Get.to(() => AdvancedVideoPlayer(url: item.videoUrl!, title: item.title));
      } else {
        CustomSnackbar.show(title: "Error", message: "Video URL not found", isError: true);
      }
    } else {
      Get.to(() => const GoPremiumPage());
    }
  }

  Widget _buildTrailerButton({required bool isDesktop}) {
    return OutlinedButton.icon(
      onPressed: () async {
        final bool? isOver18 = await Get.dialog<bool>(const AgeRestrictionPopup());
        if (isOver18 == true) {
          Get.to(() => AdvancedVideoPlayer(url: widget.content.trailerUrl!, title: '${widget.content.title} - Trailer'));
        }
      },
      icon: const Icon(Icons.play_circle_outline, size: 28, color: Colors.white),
      label: const Text("TRAILER", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 2),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20, vertical: isDesktop ? 22 : 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSmallActionsRow() {
    return Obx(() {
      final String contentId = widget.content.id;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circleActionBtn(
            icon: watchlistController.isInWatchlist(contentId) ? Icons.check : Icons.add,
            label: "Watchlist",
            onTap: () => watchlistController.toggleWatchlist(contentId),
          ),
          const SizedBox(width: 25),
          _circleActionBtn(
            icon: interactionController.isLiked(contentId) ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: "Like",
            onTap: () => interactionController.toggleLike(contentId: contentId, contentType: widget.content.contentType),
          ),
          const SizedBox(width: 25),
          _circleActionBtn(
            icon: Icons.share_outlined,
            label: "Share",
            onTap: () => ShareService.shareContent(title: widget.content.title, imageUrl: widget.content.poster),
          ),
        ],
      );
    });
  }

  Widget _circleActionBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white38)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildEpisodesSection(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Episodes",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),

        /// SEASON SELECTOR (Modern Underline style)
        Row(
          children: List.generate(widget.content.totalSeasons ?? 1, (index) {
            int seasonNum = index + 1;
            return Obx(() {
              bool isSelected = controller.selectedSeason.value == seasonNum;
              return GestureDetector(
                onTap: () => controller.selectedSeason.value = seasonNum,
                child: Container(
                  margin: const EdgeInsets.only(right: 30),
                  padding: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 3))),
                  child: Text("SEASON $seasonNum",
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white38,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              );
            });
          }),
        ),

        /// EPISODES LIST (Clean Rows)
        Obx(() {
          if (contentController.isEpisodesLoading.value) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary)));
          }
          final episodes = contentController.seriesEpisodes
              .where((item) => item.seasonNumber == controller.selectedSeason.value)
              .toList();
          if (episodes.isEmpty) {
            return const Text("Episodes are coming soon.",
                style: TextStyle(color: Colors.white38, fontSize: 14));
          }

          return ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: episodes.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white10, height: 20),
            itemBuilder: (context, index) =>
                _buildEpisodeRow(episodes[index], isDesktop),
          );
        }),
      ],
    );
  }

  Widget _buildEpisodeRow(ContentModel ep, bool isDesktop) {
    return InkWell(
      onTap: () => _playEpisode(ep),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// NUMBER
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 15),
            child: Text("${ep.episodeNumber}",
                style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),

          /// THUMBNAIL
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(ep.poster,
                    width: isDesktop ? 220 : 130,
                    height: isDesktop ? 125 : 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                        AppImages.farzi,
                        width: 130,
                        height: 75,
                        fit: BoxFit.cover)),
              ),
              const Icon(Icons.play_circle_fill, color: Colors.white70, size: 36),
            ],
          ),

          const SizedBox(width: 20),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(ep.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Text(ep.duration ?? "24m",
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ep.description ??
                      "Watch episode ${ep.episodeNumber} of ${widget.content.title}.",
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// DOWNLOAD BUTTON
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white70, size: 28),
            onPressed: () => _downloadEpisode(ep),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Cast & Crew", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.content.cast!.length,
            itemBuilder: (context, index) {
              final actor = widget.content.cast![index];
              return GestureDetector(
                onTap: () => Get.to(() => CastDetailsPage(castName: actor.name, castImage: actor.image)),
                child: Padding(
                  padding: const EdgeInsets.only(right: 35),
                  child: Column(
                    children: [
                      CircleAvatar(radius: 50, backgroundImage: NetworkImage(actor.image)),
                      const SizedBox(height: 12),
                      Text(actor.name, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
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

  Widget _buildRelatedSection(List<ContentModel> related, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("More Like This", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            itemBuilder: (context, index) {
              final item = related[index];
              return GestureDetector(
                onTap: () => Get.to(() => DramaDetailsPage(isSignedIn: authController.isLoggedIn.value, content: item), preventDuplicates: false),
                child: Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 20),
                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.poster, fit: BoxFit.cover)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _playEpisode(ContentModel episode) {
    final userLoggedIn = authController.isLoggedIn.value;
    final sub = premiumController.subscriptionData.value;
    final bool isPurchased = sub != null && sub['status'] == 'active';
    _handlePlay(episode, isPurchased, userLoggedIn);
  }

  void _downloadEpisode(ContentModel episode) {
     if (!authController.isLoggedIn.value) {
      Get.to(() => const SignInPage());
      return;
    }
    downloadController.downloadVideo(episode);
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

  void _showSubscriptionDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 60),
              const SizedBox(height: 20),
              const Text("Subscription Required", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("Unlock premium content and offline downloads with our subscription plans.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text("CANCEL", style: TextStyle(color: Colors.white54)))),
                  const SizedBox(width: 15),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor), onPressed: () { Get.back(); Get.to(() => const GoPremiumPage()); }, child: const Text("EXPLORE PLANS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
