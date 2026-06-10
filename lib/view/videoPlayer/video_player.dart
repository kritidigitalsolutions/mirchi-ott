import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final RxString quality = "Auto".obs;

  @override
  void initState() {
    super.initState();
    controller.initializeVideo(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            const SizedBox(width: 20),

                            /// 🔊 VOLUME
                            const Icon(Icons.volume_up, color: Colors.white, size: 20),
                            SizedBox(
                              width: 100,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                ),
                                child: Slider(
                                  value: controller.volume.value,
                                  onChanged: controller.setVolume,
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
                                ),
                              ),
                            ),

                            const Spacer(),

                            /// ⚡ SPEED
                            IconButton(
                              icon: const Icon(Icons.speed, color: Colors.white),
                              onPressed: () => _showSpeedDialog(context),
                            ),

                            /// 🎬 QUALITY
                            IconButton(
                              icon: const Icon(Icons.hd, color: Colors.white),
                              onPressed: () => _showQualityDialog(context),
                            ),

                            /// 📺 FULLSCREEN
                            IconButton(
                              icon: Icon(
                                controller.isFullscreen.value
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
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

  /// 🎬 QUALITY DIALOG (UI only)
  void _showQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("Quality"),
        children: ["Auto", "1080p", "720p", "480p"].map((q) {
          return SimpleDialogOption(
            onPressed: () {
              quality.value = q;
              Navigator.pop(context);
            },
            child: Text(q),
          );
        }).toList(),
      ),
    );
  }
}
