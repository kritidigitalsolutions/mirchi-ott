import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class InteractionRepository {
  final BaseApiService apiProvider;

  InteractionRepository(this.apiProvider);

  Future<Map<String, dynamic>?> getInteractionStats(String contentId) async {
    try {
      final response = await apiProvider.getApi(
        "${AppConstants.interactionStats}/$contentId",
      );
      return response;
    } catch (e) {
      print("❌ Interaction Stats Error: $e");
      return null;
    }
  }
}
