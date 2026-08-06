import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/ad_service.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../../view_model/video_player_controller/video_controller.dart';

class AdvancedVideoPlayer extends StatefulWidget {
  final String url;
  final String title;

  const AdvancedVideoPlayer({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  final VideoController controller = Get.put(VideoController());
  final RxBool isLocked = false.obs;

  @override
  void initState() {
    super.initState();
    // Initialize video playback
    if (widget.url.startsWith('http')) {
      // Show Meta Ad before playing video only for online content
      // AdService.showInterstitialAd(onComplete: () {
        if (mounted) {
          controller.initializeVideo(widget.url);
        }
      // });
    } else {
      // Local content (Downloads), play immediately without ad delay
      controller.initializeVideo(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.isFullscreen.value) {
          controller.toggleFullscreen();
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
        if (!controller.isInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            /// 🎬 VIDEO
            Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller
                      .videoPlayerController!
                      .value
                      .aspectRatio,
                  child: VideoPlayer(
                      controller.videoPlayerController!),
                ),
              ),
            ),

            /// 👆 TAPPABLE OVERLAY (Always active to catch mouse/touch events)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.toggleControls(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

            /// 🔒 LOCK BUTTON
            Obx(() => controller.showControls.value ? Positioned(
              left: 20,
              top: MediaQuery.of(context).size.height / 2 - 25,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                  padding: const EdgeInsets.all(12),
                ),
                icon: Icon(
                  isLocked.value ? Icons.lock : Icons.lock_open,
                  color: isLocked.value ? Colors.red : Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  isLocked.value = !isLocked.value;
                  controller.showControls.value = true;
                  controller.toggleControls(); // Reset hide timer
                },
              ),
            ) : const SizedBox.shrink()),

            /// 🎮 CONTROLS
            Obx(() => controller.showControls.value && !isLocked.value
              ? Positioned.fill(child: _controls(context))
              : const SizedBox.shrink()),
          ],
        );
      }),
    ),
  );
}

  /// 🎮 CONTROLS
  Widget _controls(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.toggleControls(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black45, // Slightly darker for better visibility
        child: Column(
          children: [
            /// 🔝 TOP BAR
            /// 🔝 TOP BAR
            SafeArea(
              child: Row(
                children: [
                  Responsive.backButton(context, onPressed: () => Get.back()),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      Share.share(widget.url);
                    },
                  ),
                ],
              ),
            ),

            /// ▶️ CENTER PLAY
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    onPressed: () {
                      final current = controller.videoPlayerController!.value.position;
                      controller.videoPlayerController!
                          .seekTo(current - const Duration(seconds: 10));
                    },
                  ),
                  const SizedBox(width: 40),
                  Obx(() => IconButton(
                        iconSize: 70,
                        icon: Icon(
                          controller.isPlaying.value
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                        ),
                        onPressed: controller.togglePlay,
                      )),
                  const SizedBox(width: 40),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    onPressed: () {
                      final current = controller.videoPlayerController!.value.position;
                      controller.videoPlayerController!
                          .seekTo(current + const Duration(seconds: 10));
                    },
                  ),
                ],
              ),
            ),

            /// ⬇ BOTTOM CONTROLS
            SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    /// 🔥 SEEK BAR
                    Obx(() {
                      final total = controller.totalDuration.value.inSeconds;
                      final current = controller.currentPosition.value.inSeconds;

                      final progress = total == 0 ? 0.0 : current / total;

                      return Slider(
                        value: progress,
                        onChanged: controller.seekTo,
                        activeColor: Colors.red,
                        inactiveColor: Colors.white30,
                      );
                    }),

                    /// ⏱ TIME + OPTIONS
                    Obx(() => Row(
                          children: [
                            Text(
                              "${_format(controller.currentPosition.value)} / ${_format(controller.totalDuration.value)}",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            
                            const Spacer(),

                            /// ⚡ SPEED
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.speed, color: Colors.white, size: 24),
                              onPressed: () => _showSpeedDialog(context),
                            ),
                            const SizedBox(width: 15),

                            /// 🎬 QUALITY
                            InkWell(
                              onTap: () => _showQualityDialog(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  controller.selectedQuality.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),

                            /// 📺 FULLSCREEN
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                controller.isFullscreen.value
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: controller.toggleFullscreen,
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ⏱ FORMAT
  String _format(Duration d) {
    String two(int n) =>
        n.toString().padLeft(2, "0");
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  /// ⚡ SPEED DIALOG
  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("Speed"),
        children: [0.5, 1, 1.5, 2].map((e) {
          return SimpleDialogOption(
            onPressed: () {
              controller.setPlaybackSpeed(e.toDouble());
              Navigator.pop(context);
            },
            child: Text("${e}x"),
          );
        }).toList(),
      ),
    );
  }

  /// 🎬 QUALITY DIALOG
  void _showQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Obx(() => SimpleDialog(
        title: const Text("Select Quality"),
        children: controller.availableQualities.keys.map((q) {
          return SimpleDialogOption(
            onPressed: () {
              controller.setQuality(q);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Text(q),
                const Spacer(),
                if (controller.selectedQuality.value == q)
                  const Icon(Icons.check, color: Colors.red, size: 20),
              ],
            ),
          );
        }).toList(),
      )),
    );
  }
}
