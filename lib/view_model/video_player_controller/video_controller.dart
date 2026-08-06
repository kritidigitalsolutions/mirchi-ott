import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

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

  /// 🔥 HEADERS to bypass 403 Forbidden
  /// Using a Mobile User-Agent often works better for Android apps
  final Map<String, String> _headers = {
    'User-Agent': kIsWeb
        ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        : 'Mozilla/5.0 (Linux; Android 10; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Mobile Safari/537.36',
    'Accept': '*/*',
    'Connection': 'keep-alive',
  };

  @override
  void onInit() {
    super.onInit();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  /// 🔥 INIT
  Future<void> initializeVideo(String url, {Map<String, String>? qualities}) async {
    isInitialized.value = false;
    _mainUrl = url;
    selectedQuality.value = "Auto";
    availableQualities.clear();
    
    Map<String, String> qualitiesMap = {"Auto": url};

    if (qualities != null && qualities.isNotEmpty) {
      qualitiesMap.addAll(qualities);
      _sortAndAssignQualities(qualitiesMap);
    } else {
      availableQualities["Auto"] = url;
      // If it's HLS and a remote URL, try to parse qualities from master playlist
      if (url.toLowerCase().contains(".m3u8") && url.startsWith('http')) {
        await _parseHlsQualities(url);
      }
    }

    await _setupController(availableQualities[selectedQuality.value] ?? url);
  }

  /// 🛠 Internal setup for Controller
  Future<void> _setupController(String url) async {
    try {
      final oldController = videoPlayerController;
      
      if (!kIsWeb && !url.startsWith('http')) {
        // It's a local file path
        final file = File(url);
        if (url.toLowerCase().contains('.m3u8')) {
          // For local HLS, use networkUrl with file scheme and HLS hint
          videoPlayerController = VideoPlayerController.networkUrl(
            Uri.file(file.path),
            formatHint: VideoFormat.hls,
          );
        } else {
          videoPlayerController = VideoPlayerController.file(file);
        }
      } else {
        VideoFormat? format;
        if (url.toLowerCase().contains(".m3u8")) {
          format = VideoFormat.hls;
        } else if (url.toLowerCase().contains(".mp4")) {
          format = VideoFormat.other;
        }

        // Create headers map and add Referer/Origin if possible
        final uri = Uri.parse(url);
        final headers = Map<String, String>.from(_headers);
        try {
          headers['Referer'] = "${uri.scheme}://${uri.host}/";
          headers['Origin'] = "${uri.scheme}://${uri.host}";
        } catch (_) {}

        videoPlayerController = VideoPlayerController.networkUrl(
          uri,
          formatHint: format,
          httpHeaders: headers,
        );
      }

      await videoPlayerController!.initialize();
      
      if (oldController != null) {
        await oldController.dispose();
      }

      isInitialized.value = true;
      totalDuration.value = videoPlayerController!.value.duration;

      videoPlayerController!.play();
      videoPlayerController!.setPlaybackSpeed(playbackSpeed.value);
      videoPlayerController!.setVolume(volume.value);

      videoPlayerController!.addListener(_videoListener);
      _startHideTimer();
    } catch (e) {
      debugPrint("Video Player Error: $e");
      // If Auto fails, maybe one of the quality links works? 
      // Or show an error to user.
      isInitialized.value = true; // Stop showing loader to allow error state or retry
    }
  }

  /// 🎬 HLS Quality Parser
  Future<void> _parseHlsQualities(String masterUrl) async {
    try {
      final masterUri = Uri.parse(masterUrl);

      // Mirror the headers used in _setupController
      final headers = Map<String, String>.from(_headers);
      try {
        headers['Referer'] = "${masterUri.scheme}://${masterUri.host}/";
        headers['Origin'] = "${masterUri.scheme}://${masterUri.host}";
      } catch (_) {}

      final response = await http.get(masterUri, headers: headers);
      debugPrint("HLS Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final lines = response.body.split(RegExp(r'\r?\n'));
        Map<String, String> qualities = {"Auto": masterUrl};

        for (int i = 0; i < lines.length; i++) {
          String line = lines[i].trim();
          if (line.startsWith('#EXT-X-STREAM-INF')) {
            // Try to find NAME, RESOLUTION, or BANDWIDTH
            final nameMatch = RegExp(r'NAME="([^"]+)"', caseSensitive: false).firstMatch(line);
            final resMatch = RegExp(r'RESOLUTION=(\d+x\d+)', caseSensitive: false).firstMatch(line);
            final bwMatch = RegExp(r'BANDWIDTH=(\d+)', caseSensitive: false).firstMatch(line);

            String? qualityName;
            if (nameMatch != null) {
              qualityName = nameMatch.group(1);
            } else if (resMatch != null) {
              qualityName = "${resMatch.group(1)!.split('x').last}p";
            } else if (bwMatch != null) {
              int bandwidth = int.parse(bwMatch.group(1)!);
              if (bandwidth > 1000000) {
                qualityName = "${(bandwidth / 1000000).toStringAsFixed(1)}M";
              } else {
                qualityName = "${(bandwidth / 1000).toInt()}k";
              }
            }

            if (qualityName != null) {
              // The next non-empty line that isn't a comment is the URL
              for (int j = i + 1; j < lines.length; j++) {
                String nextLine = lines[j].trim();
                if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
                  // Resolve relative URL
                  Uri qualityUri;
                  if (nextLine.startsWith('http')) {
                    qualityUri = Uri.parse(nextLine);
                  } else {
                    qualityUri = masterUri.resolve(nextLine);
                    
                    // Preserve query parameters from master playlist if needed
                    if (masterUri.hasQuery && !qualityUri.hasQuery) {
                       qualityUri = qualityUri.replace(queryParameters: masterUri.queryParameters);
                    }
                  }

                  qualities[qualityName] = qualityUri.toString();
                  break;
                }
              }
            }
          }
        }

        debugPrint("Found Qualities: ${qualities.keys.toList()}");

        if (qualities.length > 1) {
          _sortAndAssignQualities(qualities);
        }
      } else {
        debugPrint("Failed to fetch master playlist: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error parsing HLS: $e");
    }
  }

  void _sortAndAssignQualities(Map<String, String> qualities) {
    final List<String> priorityOrder = ["Auto", "1080p", "720p", "480p", "360p", "240p"];
    final Map<String, String> sorted = {};

    for (var q in priorityOrder) {
      if (qualities.containsKey(q)) {
        sorted[q] = qualities[q]!;
      }
    }

    qualities.forEach((key, value) {
      if (!sorted.containsKey(key)) {
        sorted[key] = value;
      }
    });

    availableQualities.assignAll(sorted);
  }

  void _videoListener() {
    if (videoPlayerController == null) return;
    final value = videoPlayerController!.value;
    currentPosition.value = value.position;
    isPlaying.value = value.isPlaying;
    if (value.duration != Duration.zero) {
      totalDuration.value = value.duration;
    }
    
    // Handle playback error during stream
    if (value.hasError) {
      debugPrint("Video Player Listener Error: ${value.errorDescription}");
    }
  }

  /// 🎬 CHANGE QUALITY
  Future<void> setQuality(String quality) async {
    if (selectedQuality.value == quality) return;
    if (!availableQualities.containsKey(quality)) return;

    final currentPos = videoPlayerController?.value.position ?? Duration.zero;
    final wasPlaying = videoPlayerController?.value.isPlaying ?? false;

    selectedQuality.value = quality;
    isInitialized.value = false;

    await _setupController(availableQualities[quality]!);
    
    if (videoPlayerController != null) {
      await videoPlayerController!.seekTo(currentPos);
      if (wasPlaying) {
        videoPlayerController!.play();
      }
    }
  }

  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;
    if (!kIsWeb) {
      if (isFullscreen.value) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
  }

  void togglePlay() {
    final c = videoPlayerController;
    if (c == null) return;
    c.value.isPlaying ? c.pause() : {c.play(), _startHideTimer()};
  }

  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value) _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () => showControls.value = false);
  }

  void seekTo(double value) {
    final c = videoPlayerController;
    if (c == null) return;
    final duration = c.value.duration;
    if (duration.inSeconds == 0) return;
    c.seekTo(Duration(seconds: (duration.inSeconds * value).toInt()));
    _startHideTimer();
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    videoPlayerController?.setPlaybackSpeed(speed);
  }

  void setVolume(double value) {
    volume.value = value;
    videoPlayerController?.setVolume(value);
  }

  @override
  void onClose() {
    _hideTimer?.cancel();
    videoPlayerController?.removeListener(_videoListener);
    videoPlayerController?.dispose();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.onClose();
  }
}
