import 'package:flutter/foundation.dart';
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
  var volume = 1.0.obs;

  Timer? _hideTimer;

  // --- Quality Features ---
  var availableQualities = <String, String>{}.obs;
  var selectedQuality = "Auto".obs;
  String? _mainUrl;

  /// 🔥 INIT
  Future<void> initializeVideo(String url, {Map<String, String>? qualities}) async {
    isInitialized.value = false;
    _mainUrl = url;

    // Setup available qualities. 
    // In a real scenario, these come from your API.
    if (qualities != null && qualities.isNotEmpty) {
      availableQualities.value = qualities;
      if (!availableQualities.containsKey("Auto")) {
        availableQualities["Auto"] = url;
      }
    } else {
      // Mocking qualities if none provided, using the same URL 
      // In HLS (m3u8), "Auto" is handled by the player natively for adaptive bitrate.
      availableQualities.value = {
        "Auto": url,
        "1080p": url,
        "720p": url,
        "480p": url,
        "360p": url,
      };
    }

    await _setupController(availableQualities[selectedQuality.value] ?? url);
  }

  /// 🛠 Internal setup for Controller
  Future<void> _setupController(String url) async {
    final oldController = videoPlayerController;
    
    // Pre-initialize new one
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await videoPlayerController!.initialize();
      
      // Dispose old one after new one is ready to avoid black screen flicker if possible
      if (oldController != null) {
        await oldController.dispose();
      }

      isInitialized.value = true;
      totalDuration.value = videoPlayerController!.value.duration;

      videoPlayerController!.play();
      videoPlayerController!.setPlaybackSpeed(playbackSpeed.value);
      videoPlayerController!.setVolume(volume.value);

      // Preferred orientations
      if (!kIsWeb) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }

      /// 🔥 LISTENER
      videoPlayerController!.addListener(_videoListener);
      _startHideTimer();
    } catch (e) {
      debugPrint("Video Player Error: $e");
    }
  }

  void _videoListener() {
    if (videoPlayerController == null) return;
    final value = videoPlayerController!.value;
    currentPosition.value = value.position;
    isPlaying.value = value.isPlaying;
    if (value.duration != Duration.zero) {
      totalDuration.value = value.duration;
    }
  }

  /// 🎬 CHANGE QUALITY
  Future<void> setQuality(String quality) async {
    if (selectedQuality.value == quality) return;
    if (!availableQualities.containsKey(quality)) return;

    final currentPos = videoPlayerController?.value.position ?? Duration.zero;
    final wasPlaying = videoPlayerController?.value.isPlaying ?? false;

    selectedQuality.value = quality;
    isInitialized.value = false; // Show loader during switch

    await _setupController(availableQualities[quality]!);
    
    if (videoPlayerController != null) {
      await videoPlayerController!.seekTo(currentPos);
      if (wasPlaying) {
        videoPlayerController!.play();
      } else {
        videoPlayerController!.pause();
      }
    }
  }

  /// 📺 FULLSCREEN TOGGLE
  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;

    if (!kIsWeb) {
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

  /// 🔊 VOLUME
  void setVolume(double value) {
    volume.value = value;
    videoPlayerController?.setVolume(value);
  }

  /// ❌ DISPOSE
  @override
  void onClose() {
    _hideTimer?.cancel();
    videoPlayerController?.removeListener(_videoListener);
    videoPlayerController?.dispose();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.onClose();
  }
}
