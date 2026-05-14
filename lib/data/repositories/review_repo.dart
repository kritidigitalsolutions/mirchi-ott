import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class ReviewRepo {
  final BaseApiService api;

  ReviewRepo({required this.api});

  /// ⭐ Submit Rating API
  Future<dynamic> submitRating({
    required int rating,
    required String review,
  }) async {
    try {
      final response = await api.postApi(
        AppConstants.rateApp,
        {
          "rating": rating,
          "review": review,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
