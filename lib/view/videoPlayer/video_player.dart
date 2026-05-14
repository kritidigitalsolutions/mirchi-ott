import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../../view_model/video_player_controller/video_controller.dart';

class AdvancedVideoPlayer extends StatelessWidget {
  final String url;
  final String title;

  AdvancedVideoPlayer({
    super.key,
    required this.url,
    required this.title,
  });

  final VideoController controller = Get.put(VideoController());

  final RxBool isLocked = false.obs;
  final RxString quality = "Auto".obs;

  @override
  Widget build(BuildContext context) {
    controller.initializeVideo(url);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GestureDetector(
          onTap: () {
            if (!isLocked.value) {
              controller.toggleControls();
            }
          },
          child: Stack(
            children: [
              /// 🎬 VIDEO
              Center(
                child: AspectRatio(
                  aspectRatio: controller
                      .videoPlayerController!
                      .value
                      .aspectRatio,
                  child: VideoPlayer(
                      controller.videoPlayerController!),
                ),
              ),

              /// 🔒 LOCK BUTTON
              Positioned(
                left: 10,
                top: MediaQuery.of(context).size.height / 2,
                child: Obx(() => IconButton(
                  icon: Icon(
                    isLocked.value
                        ? Icons.lock
                        : Icons.lock_open,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    isLocked.value = !isLocked.value;
                    controller.showControls.value =
                    !isLocked.value;
                  },
                )),
              ),

              /// 🎮 CONTROLS
              Obx(() => controller.showControls.value &&
                  !isLocked.value
                  ? _controls(context)
                  : const SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  /// 🎮 CONTROLS
  Widget _controls(BuildContext context) {
    return Column(
      children: [
        /// 🔝 TOP BAR
        SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share,
                    color: Colors.white),
                onPressed: () {
                  Share.share(url);
                },
              ),
            ],
          ),
        ),

        /// ▶️ CENTER PLAY
        Expanded(
          child: Center(
            child: Obx(() => IconButton(
              iconSize: 70,
              icon: Icon(
                controller.isPlaying.value
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: controller.togglePlay,
            )),
          ),
        ),

        /// ⬇ BOTTOM CONTROLS
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              /// 🔥 SEEK BAR
              Obx(() {
                final total =
                    controller.totalDuration.value.inSeconds;
                final current =
                    controller.currentPosition.value.inSeconds;

                final progress =
                total == 0 ? 0.0 : current / total;

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
                    style: const TextStyle(
                        color: Colors.white),
                  ),
                  const Spacer(),

                  /// ⚡ SPEED
                  IconButton(
                    icon: const Icon(Icons.speed,
                        color: Colors.white),
                    onPressed: () =>
                        _showSpeedDialog(context),
                  ),

                  /// 🎬 QUALITY
                  IconButton(
                    icon: const Icon(Icons.hd,
                        color: Colors.white),
                    onPressed: () =>
                        _showQualityDialog(context),
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
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
