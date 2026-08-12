import 'package:get/get.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/review_repo.dart';
import '../../utils/custom_snackbar.dart';

class ReviewController extends GetxController {
  final ReviewRepo repo =
  ReviewRepo(api: Get.find<BaseApiService>());

  /// ⭐ States
  var rating = 0.obs;
  var comment = ''.obs;
  var isLoading = false.obs; // ✅ ADD THIS

  /// ⭐ Update Rating
  void updateRating(int value) {
    rating.value = value;
  }

  /// ✍️ Update Comment
  void updateComment(String value) {
    comment.value = value;
  }

  /// 🚀 Submit Review
  Future<void> submitReview() async {
    if (rating.value == 0) {
      CustomSnackbar.show(title: "Error", message: "Please select rating", isError: true);
      return;
    }

    try {
      isLoading.value = true; // ✅ USE HERE

      final response = await repo.submitRating(
        rating: rating.value,
        review: comment.value,
      );

      if (response['success'] == true) {
        CustomSnackbar.show(title: "Success", message: response['message'], isSuccess: true);

        /// Reset
        rating.value = 0;
        comment.value = "";

        Get.back();
      } else {
        CustomSnackbar.show(title: "Error", message: "Something went wrong", isError: true);
      }
    } catch (e) {
      CustomSnackbar.show(title: "Error", message: e.toString(), isError: true);
    } finally {
      isLoading.value = false; // ✅ STOP LOADER
    }
  }
}
