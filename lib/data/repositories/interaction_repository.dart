import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class InteractionRepository {
  final BaseApiService apiProvider;

  InteractionRepository(this.apiProvider);

  /// 📊 GET INTERACTION STATS & USER STATUS
  Future<Map<String, dynamic>?> getInteractionStats(String contentId) async {
    try {
      final response = await apiProvider.getApi(
        "${AppConstants.interactionStats}/$contentId",
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      print("❌ Interaction Stats Error: $e");
      return null;
    }
  }

  /// 👍👎 TOGGLE INTERACTION (LIKE/DISLIKE)
  Future<Map<String, dynamic>?> toggleInteraction({
    required String contentId,
    required String contentType,
    required String type,
  }) async {
    try {
      final response = await apiProvider.postApi(
        AppConstants.toggleInteraction,
        {
          "contentId": contentId,
          "contentType": contentType,
          "type": type,
        },
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      print("❌ Toggle Interaction Error: $e");
      return null;
    }
  }
}
