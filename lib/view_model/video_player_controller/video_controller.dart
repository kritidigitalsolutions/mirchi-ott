import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  VideoPlayerController? videoPlayerController;

  var isInitialized = false.obs;
  var isPlaying = false.obs;
  var showControls = true.obs;
  var isFullscreen = false.obs;

  var currentPosition = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;

  var playbackSpeed = 1.0.obs;

  Timer? _hideTimer;

  /// 🔥 INIT
  Future<void> initializeVideo(String url) async {
    isInitialized.value = false;

    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(url));

    await videoPlayerController!.initialize();

    isInitialized.value = true;
    totalDuration.value =
        videoPlayerController!.value.duration;

    videoPlayerController!.play();

    /// 🔥 LISTENER (REAL-TIME UPDATE)
    videoPlayerController!.addListener(() {
      final value = videoPlayerController!.value;

      currentPosition.value = value.position;
      isPlaying.value = value.isPlaying;

      if (value.duration != null) {
        totalDuration.value = value.duration;
      }
    });

    _startHideTimer();
  }

  /// 📺 FULLSCREEN TOGGLE
  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;

    if (isFullscreen.value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  /// ▶️ PLAY / PAUSE
  void togglePlay() {
    final c = videoPlayerController;
    if (c == null) return;

    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
      _startHideTimer();
    }
  }

  /// 👆 CONTROLS
  void toggleControls() {
    showControls.value = !showControls.value;

    if (showControls.value) {
      _startHideTimer();
    }
  }

  /// ⏱ AUTO HIDE
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      showControls.value = false;
    });
  }

  /// ⏩ SEEK
  void seekTo(double value) {
    final c = videoPlayerController;
    if (c == null) return;

    final duration = c.value.duration;
    if (duration.inSeconds == 0) return;

    final newPos = Duration(
      seconds: (duration.inSeconds * value).toInt(),
    );

    c.seekTo(newPos);
    _startHideTimer();
  }

  /// ⚡ SPEED
  void setPlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    videoPlayerController?.setPlaybackSpeed(speed);
  }

  /// ❌ DISPOSE
  @override
  void onClose() {
    _hideTimer?.cancel();
    videoPlayerController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }
}
