import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class WatchlistRepo {
  final BaseApiService apiProvider;

  WatchlistRepo({required this.apiProvider});

  /// 📥 GET WATCHLIST
  Future<dynamic> getWatchlist() async {
    try {
      final response = await apiProvider.getApi(
        AppConstants.getWatchlist,
      );
      return response;
    } catch (e) {
      print("❌ Get Watchlist Error: $e");
      rethrow;
    }
  }

  /// ➕ ADD TO WATCHLIST
  Future<dynamic> addToWatchlist(String contentId) async {
    try {
      final response = await apiProvider.postApi(
        AppConstants.addWatchlist,
        {
          "movieId": contentId,
        },
      );
      return response;
    } catch (e) {
      print("❌ Add Watchlist Error: $e");
      rethrow;
    }
  }

  /// ❌ REMOVE FROM WATCHLIST
  Future<dynamic> removeFromWatchlist(String watchlistId) async {
    try {
      final response = await apiProvider.deleteApi(
        "${AppConstants.removeWatchlist}/$watchlistId",
        {},
      );
      return response;
    } catch (e) {
      print("❌ Remove Watchlist Error: $e");
      rethrow;
    }
  }
}
