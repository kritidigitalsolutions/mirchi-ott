import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../data/models/watch_tracking/watch_tracking_model.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/watch_repository.dart';

class AnalyticsController extends GetxController with WidgetsBindingObserver {
  static AnalyticsController get to => Get.find<AnalyticsController>();

  late final WatchRepository _watchRepository;

  // Cached device ID
  String? _cachedDeviceId;

  // Active watch tracking state
  String? currentSessionId;
  String? currentEpisodeId;
  int? currentDurationSec;
  Timer? _heartbeatTimer;

  int _accumulatedDeltaSec = 0;
  int _lastPositionSec = 0;
  DateTime? _lastTickTime;
  bool _isPlaying = false;
  bool isSessionActive = false;

  // Continue Watching state
  final RxList<ContinueWatchingItem> continueWatchingList =
      <ContinueWatchingItem>[].obs;
  final RxBool isContinueWatchingLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final baseApi = Get.find<BaseApiService>();
    _watchRepository = WatchRepository(apiProvider: baseApi);
    getDeviceId(); // pre-warm device ID
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (isSessionActive) {
        onPause(positionSec: _lastPositionSec);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (isSessionActive && _isPlaying) {
        onPlay();
      }
    }
  }

  // ==========================================
  // 🔑 Helper: Stable Device ID & UUID
  // ==========================================

  /// Generate a valid UUID v4 (8-100 chars, letters, numbers, `-` or `_`)
  String generateUuid() {
    final Random random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // version 4
    values[8] = (values[8] & 0x3f) | 0x80; // variant
    return [
      values.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      values.sublist(4, 6).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      values.sublist(6, 8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      values.sublist(8, 10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      values.sublist(10, 16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    ].join('-');
  }

  /// Get or create a persistent, stable device identifier
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }
    try {
      var box = Hive.box('appBox');
      String? savedId = box.get('deviceId');
      if (savedId != null && savedId.isNotEmpty) {
        _cachedDeviceId = savedId;
        return savedId;
      }

      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String? id;

      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        id = 'web_${webInfo.userAgent.hashCode.toRadixString(16)}_${generateUuid().substring(0, 8)}';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id.isNotEmpty ? androidInfo.id : generateUuid();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? generateUuid();
      } else {
        id = generateUuid();
      }

      await box.put('deviceId', id);
      _cachedDeviceId = id;
      return id;
    } catch (e) {
      final fallback = generateUuid();
      _cachedDeviceId = fallback;
      return fallback;
    }
  }

  /// Detect platform: 'android', 'ios', 'web', or 'other'
  String getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  // ==========================================
  // 🎬 Watch Tracking: Start, Heartbeat & Stop
  // ==========================================

  /// Start a new playback tracking session for an episode
  Future<void> startWatching({
    required String episodeId,
    int? durationSec,
  }) async {
    // End any existing session cleanly
    if (isSessionActive) {
      await stopWatching(positionSec: _lastPositionSec);
    }

    final sessionId = generateUuid();
    final deviceId = await getDeviceId();
    final platform = getPlatform();

    currentSessionId = sessionId;
    currentEpisodeId = episodeId;
    currentDurationSec = durationSec;

    _accumulatedDeltaSec = 0;
    _lastPositionSec = 0;
    _lastTickTime = DateTime.now();
    _isPlaying = true;
    isSessionActive = true;

    debugPrint("🎬 [Watch Tracking] START: episodeId=$episodeId, sessionId=$sessionId, platform=$platform");

    // Call /api/watch/start (Fire-and-forget)
    _watchRepository.startWatchSession(
      WatchStartRequest(
        episodeId: episodeId,
        sessionId: sessionId,
        platform: platform,
        deviceId: deviceId,
        durationSec: durationSec,
      ),
    );

    // Schedule 30-second progress heartbeat
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendHeartbeat(isPeriodic: true);
    });
  }

  /// Called continuously by video listener to update current position and delta
  void updatePosition(int positionSec) {
    if (!isSessionActive) return;

    if (_isPlaying && _lastTickTime != null) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTickTime!).inSeconds;
      if (elapsed > 0) {
        // Cap single tick delta to prevent clock jumps
        _accumulatedDeltaSec += min(elapsed, 4);
        _lastTickTime = now;
      }
    }
    _lastPositionSec = positionSec;
  }

  /// Play event
  void onPlay() {
    _isPlaying = true;
    _lastTickTime = DateTime.now();
  }

  /// Pause event: sends heartbeat immediately on pause
  void onPause({int? positionSec}) {
    if (positionSec != null) {
      updatePosition(positionSec);
    }
    _isPlaying = false;
    _lastTickTime = null;
    _sendHeartbeat();
  }

  /// Seek event: sets new position without counting seek jump into deltaSec
  void onSeek(int newPositionSec) {
    _lastPositionSec = newPositionSec;
    _lastTickTime = DateTime.now();
  }

  /// Episode end event: sends final heartbeat
  void onEpisodeEnd({required int positionSec}) {
    updatePosition(positionSec);
    _sendHeartbeat();
    stopWatching(positionSec: positionSec);
  }

  /// Stop session: on player close or screen exit
  Future<void> stopWatching({int? positionSec}) async {
    if (!isSessionActive) return;

    if (positionSec != null) {
      updatePosition(positionSec);
    }

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    // Send final heartbeat if watched time is remaining
    if (_accumulatedDeltaSec > 0 || _lastPositionSec > 0) {
      await _sendHeartbeat();
    }

    isSessionActive = false;
    _isPlaying = false;
    _lastTickTime = null;
    debugPrint("🎬 [Watch Tracking] STOPPED: sessionId=$currentSessionId");
    currentSessionId = null;
    currentEpisodeId = null;
    currentDurationSec = null;
  }

  /// Internal: Send progress heartbeat to /api/watch/progress
  Future<void> _sendHeartbeat({bool isPeriodic = false}) async {
    final sessionId = currentSessionId;
    if (sessionId == null) return;

    final delta = _accumulatedDeltaSec;
    _accumulatedDeltaSec = 0; // reset to 0 after send
    final position = _lastPositionSec;

    // If periodic and user hasn't watched anything (paused/buffering), skip call
    if (isPeriodic && delta == 0 && !_isPlaying) {
      return;
    }

    debugPrint("💓 [Watch Tracking] HEARTBEAT: session=$sessionId, pos=$position, delta=$delta");

    try {
      await _watchRepository.sendWatchProgress(
        WatchProgressRequest(
          sessionId: sessionId,
          positionSec: position,
          deltaSec: delta,
        ),
      );
    } catch (e) {
      debugPrint("⚠️ [Watch Tracking] Progress Error: $e");
      // Handle 404: Session not found -> re-call /start with same sessionId as documented
      if (e.toString().contains("404") || e.toString().contains("Session not found")) {
        debugPrint("🔄 [Watch Tracking] 404 detected. Re-calling /start with same sessionId");
        final episodeId = currentEpisodeId;
        if (episodeId != null) {
          final deviceId = await getDeviceId();
          await _watchRepository.startWatchSession(
            WatchStartRequest(
              episodeId: episodeId,
              sessionId: sessionId,
              platform: getPlatform(),
              deviceId: deviceId,
              durationSec: currentDurationSec,
            ),
          );
          // Retry progress once
          try {
            await _watchRepository.sendWatchProgress(
              WatchProgressRequest(
                sessionId: sessionId,
                positionSec: position,
                deltaSec: delta,
              ),
            );
          } catch (_) {}
        }
      }
    }
  }

  // ==========================================
  // 🔗 Share Tracking: /api/watch/share
  // ==========================================

  /// Record share action for a series or episode
  Future<void> trackShare({
    required String seriesId,
    String? episodeId,
  }) async {
    final deviceId = await getDeviceId();
    final platform = getPlatform();

    debugPrint("🔗 [Watch Tracking] SHARE: seriesId=$seriesId, episodeId=$episodeId");

    _watchRepository.recordWatchShare(
      WatchShareRequest(
        seriesId: seriesId,
        episodeId: episodeId,
        platform: platform,
        deviceId: deviceId,
      ),
    );
  }

  // ==========================================
  // 📺 Continue Watching: /api/watch/continue
  // ==========================================

  /// Fetch user's in-progress watch history
  Future<void> fetchContinueWatching({int limit = 20}) async {
    try {
      isContinueWatchingLoading.value = true;
      final response =
          await _watchRepository.getContinueWatching(limit: limit);
      if (response != null && response.success) {
        continueWatchingList.assignAll(response.items);
        debugPrint("📺 [Watch Tracking] Fetched ${continueWatchingList.length} continue watching items");
      }
    } catch (e) {
      debugPrint("❌ [Watch Tracking] Error fetching continue watching: $e");
    } finally {
      isContinueWatchingLoading.value = false;
    }
  }
}
