import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/routes/app_routes.dart';
import 'package:mirchi_ott/widgets/custom_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:mirchi_ott/app/theme/app_colors.dart';
import 'package:mirchi_ott/data/models/shorts_model.dart';
import 'package:mirchi_ott/view_model/shorts_controller/shorts_controller.dart';
import 'package:mirchi_ott/view_model/auth_controller/auth_controller.dart';

class ShortsPage extends StatelessWidget {
  const ShortsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ShortsController controller = Get.put(ShortsController());

    return Container(
      color: AppColors.black,
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
              }
              
              if (controller.shortDramas.isEmpty) {
                return const Center(
                  child: Text("No short dramas found", style: TextStyle(color: Colors.white)),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchShortDramas,
                color: AppColors.buttonColor,
                child: ListView.builder(
                  itemCount: controller.shortDramas.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    return ShortDramaListItem(drama: controller.shortDramas[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ShortDramaListItem extends StatefulWidget {
  final ShortDrama drama;
  const ShortDramaListItem({super.key, required this.drama});

  @override
  State<ShortDramaListItem> createState() => _ShortDramaListItemState();
}

class _ShortDramaListItemState extends State<ShortDramaListItem> {
  final ShortsController shortsController = Get.find<ShortsController>();
  final AuthController authController = Get.find<AuthController>();
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  List<ShortEpisode>? _episodes;

  @override
  void initState() {
    super.initState();
    if (authController.isLoggedIn.value) {
      _loadFirstEpisode();
    }
  }

  Future<void> _loadFirstEpisode() async {
    _episodes = await shortsController.fetchEpisodes(widget.drama.id);
    if (_episodes != null && _episodes!.isNotEmpty && mounted) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(_episodes![0].videoUrl),
      )..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
              _controller?.setLooping(true);
              _controller?.setVolume(0); // Mute for autoplay
              _controller?.play();
            });
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            /// Banner
            GestureDetector(
              onTap: () async {
                if (_episodes == null || _episodes!.isEmpty) {
                   _episodes = await shortsController.fetchEpisodes(widget.drama.id);
                }
                if (_episodes != null && _episodes!.isNotEmpty) {
                  Get.toNamed(AppRoutes.shortsPlayer, arguments: {
                    'episodes': _episodes!,
                    'initialIndex': 0,
                    'dramaName': widget.drama.title,
                  });
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.38,
                width: double.infinity,
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// Video / Image
                    Positioned.fill(
                      child: _isInitialized && _controller != null && authController.isLoggedIn.value
                          ? FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller!.value.size.width,
                                height: _controller!.value.size.height,
                                child: VideoPlayer(_controller!),
                              ),
                            )
                          : CustomNetworkImage(
                              imageUrl: widget.drama.banner,
                              fit: BoxFit.cover,
                            ),
                    ),

                    /// Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.85),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// Play Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),

                    /// Bottom Content
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Drama Name
                          Text(
                            widget.drama.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          /// Details
                          Text(
                            "${widget.drama.language} • ${widget.drama.totalEpisodes} Episodes",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          /// View Episodes Button
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.shortsEpisodes, arguments: widget.drama);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                "View Episodes",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
