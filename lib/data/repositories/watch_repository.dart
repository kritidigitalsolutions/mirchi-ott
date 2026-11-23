import '../network/base_api_service.dart';
import '../../utils/constants.dart';
import '../models/watch_tracking/watch_tracking_model.dart';

class WatchRepository {
  final BaseApiService apiProvider;

  WatchRepository({required this.apiProvider});

  /// 🎬 1. Start a watch session
  Future<Map<String, dynamic>?> startWatchSession(WatchStartRequest request) async {
    try {
      final response = await apiProvider.postApi(
        AppConstants.watchStart,
        request.toJson(),
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      print("❌ Watch Start Error: $e");
      return null;
    }
  }

  /// 💓 2. Send progress heartbeat
  Future<dynamic> sendWatchProgress(WatchProgressRequest request) async {
    return await apiProvider.postApi(
      AppConstants.watchProgress,
      request.toJson(),
    );
  }

  /// 🔗 3. Record share
  Future<Map<String, dynamic>?> recordWatchShare(WatchShareRequest request) async {
    try {
      final response = await apiProvider.postApi(
        AppConstants.watchShare,
        request.toJson(),
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      print("❌ Watch Share Error: $e");
      return null;
    }
  }

  /// 📺 4. Get Continue Watching
  Future<ContinueWatchingResponse?> getContinueWatching({int limit = 20}) async {
    try {
      final response = await apiProvider.getApi(
        AppConstants.watchContinue(limit: limit),
      );
      if (response != null && response is Map<String, dynamic>) {
        return ContinueWatchingResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      print("❌ Get Continue Watching Error: $e");
      return null;
    }
  }
}
