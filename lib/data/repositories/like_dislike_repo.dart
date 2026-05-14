import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class InteractionRepository {
  final BaseApiService apiProvider;

  InteractionRepository(this.apiProvider);

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
      print("❌ Repo Error: $e");
      return null;
    }
  }
}
