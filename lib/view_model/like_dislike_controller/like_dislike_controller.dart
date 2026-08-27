import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/interaction_repository.dart';
import '../../utils/custom_snackbar.dart';
import '../auth_controller/auth_controller.dart';
import '../../view/auth/signInPage.dart';
import '../content_controller/content_controller.dart';

class InteractionController extends GetxController {
  final InteractionRepository _repo = InteractionRepository(Get.find<BaseApiService>());

  // Maps to store status for different contents: ContentID -> Status
  var likedMap = <String, bool>{}.obs;
  var dislikedMap = <String, bool>{}.obs;
  var isLoadingMap = <String, bool>{}.obs;

  bool isLiked(String contentId) => likedMap[contentId] ?? false;
  bool isDisliked(String contentId) => dislikedMap[contentId] ?? false;
  bool isLoading(String contentId) => isLoadingMap[contentId] ?? false;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    ever(authController.isLoggedIn, (bool loggedIn) {
      if (!loggedIn) {
        likedMap.clear();
        dislikedMap.clear();
        isLoadingMap.clear();
      }
    });
  }

  /// 🔄 Fetch Status for specific content
  Future<void> fetchStatus(String contentId) async {
    if (contentId.isEmpty) return;
    
    final authController = Get.find<AuthController>();
    
    // We fetch stats regardless, but user specific likes only if logged in
    try {
      final response = await _repo.getInteractionStats(contentId);
      if (response != null) {
        // Robust parsing for liked/disliked status
        if (authController.isLoggedIn.value) {
          likedMap[contentId] = _parseBool(response['userLiked']) ?? 
                                _parseBool(response['isLiked']) ?? 
                                _parseBool(response['liked']) ?? false;
                                
          dislikedMap[contentId] = _parseBool(response['userDisliked']) ?? 
                                   _parseBool(response['isDisliked']) ?? 
                                   _parseBool(response['disliked']) ?? false;
        }

        // ✅ Update global like count cache for search/UI
        if (Get.isRegistered<ContentController>()) {
          Get.find<ContentController>().contentLikes[contentId] = response['likes'] ?? 0;
        }
      }
    } catch (e) {
      print("❌ Error fetching interaction status for $contentId: $e");
    }
  }

  bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final v = value.toLowerCase();
      return v == 'true' || v == '1' || v == 'yes';
    }
    return null;
  }

  /// 👍 Toggle LIKE
  Future<void> toggleLike({
    required String contentId,
    required String contentType,
  }) async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      Get.toNamed(AppRoutes.signIn);
      return;
    }

    if (isLoading(contentId)) return;
    
    isLoadingMap[contentId] = true;
    try {
      final response = await _repo.toggleInteraction(
        contentId: contentId,
        contentType: contentType,
        type: "like",
      );

      if (response != null && response["message"] != null) {
        final message = response["message"].toString().toLowerCase();

        if (message.contains("removed")) {
          likedMap[contentId] = false;
          CustomSnackbar.show(title: "Like Removed", message: "You unliked this content");
        } else if (message.contains("added")) {
          likedMap[contentId] = true;
          dislikedMap[contentId] = false;
          CustomSnackbar.show(title: "Liked", message: "You liked this content ❤️", isSuccess: true);
        }
      }
    } catch (e) {
      print("❌ Like Toggle Error: $e");
      CustomSnackbar.show(title: "Error", message: "Failed to update like status", isError: true);
    } finally {
      isLoadingMap[contentId] = false;
    }
  }

  /// 👎 Toggle DISLIKE
  Future<void> toggleDislike({
    required String contentId,
    required String contentType,
  }) async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      Get.toNamed(AppRoutes.signIn);
      return;
    }

    if (isLoading(contentId)) return;

    isLoadingMap[contentId] = true;
    try {
      final response = await _repo.toggleInteraction(
        contentId: contentId,
        contentType: contentType,
        type: "dislike",
      );

      if (response != null && response["message"] != null) {
        final message = response["message"].toString().toLowerCase();

        if (message.contains("removed")) {
          dislikedMap[contentId] = false;
          CustomSnackbar.show(title: "Dislike Removed", message: "You removed dislike");
        } else if (message.contains("added")) {
          dislikedMap[contentId] = true;
          likedMap[contentId] = false;
          CustomSnackbar.show(title: "Disliked", message: "You disliked this content", isSuccess: true);
        }
      }
    } catch (e) {
      print("❌ Dislike Toggle Error: $e");
      CustomSnackbar.show(title: "Error", message: "Failed to update dislike status", isError: true);
    } finally {
      isLoadingMap[contentId] = false;
    }
  }
}
