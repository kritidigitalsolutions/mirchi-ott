import 'package:get/get.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/like_dislike_repo.dart';

class InteractionController extends GetxController {
  final InteractionRepository _repo = InteractionRepository(Get.find<BaseApiService>());

  var isLiked = false.obs;
  var isDisliked = false.obs;
  var isLoading = false.obs;

  /// 👍 Toggle LIKE
  Future<void> toggleLike({
    required String contentId,
    required String contentType,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await _repo.toggleInteraction(
        contentId: contentId,
        contentType: contentType,
        type: "like",
      );

      // Check message directly as 'success' might not be in response
      if (response != null && response["message"] != null) {
        final message = response["message"].toString().toLowerCase();

        if (message.contains("removed")) {
          isLiked.value = false;
        } else if (message.contains("added")) {
          isLiked.value = true;
          isDisliked.value = false;
        }
      }
    } catch (e) {
      print("❌ Like Toggle Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 👎 Toggle DISLIKE
  Future<void> toggleDislike({
    required String contentId,
    required String contentType,
  }) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final response = await _repo.toggleInteraction(
        contentId: contentId,
        contentType: contentType,
        type: "dislike",
      );

      if (response != null && response["message"] != null) {
        final message = response["message"].toString().toLowerCase();

        if (message.contains("removed")) {
          isDisliked.value = false;
        } else if (message.contains("added")) {
          isDisliked.value = true;
          isLiked.value = false;
        }
      }
    } catch (e) {
      print("❌ Dislike Toggle Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
