import 'package:get/get.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/watchlist_repo.dart';
import '../../utils/custom_snackbar.dart';
import '../auth_controller/auth_controller.dart';

class WatchlistController extends GetxController {
  final WatchlistRepo repo = WatchlistRepo(apiProvider: Get.find<BaseApiService>());

  var isLoading = false.obs;
  var watchlist = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Auth status check करें
    final authController = Get.find<AuthController>();
    
    // Initial fetch if logged in
    if (authController.isLoggedIn.value) {
      getWatchlist();
    }

    // Login status change को listen करें
    ever(authController.isLoggedIn, (bool loggedIn) {
      if (loggedIn) {
        getWatchlist();
      } else {
        watchlist.clear();
      }
    });
  }

  /// 📥 GET WATCHLIST
  Future<void> getWatchlist() async {
    try {
      isLoading.value = true;
      final response = await repo.getWatchlist();
      
      if (response != null) {
        // Checking for success true or just presence of data
        final List<dynamic> data = response['data'] ?? [];
        watchlist.assignAll(data.map((e) => e as Map<String, dynamic>).toList());
        print("✅ WATCHLIST FETCHED: ${watchlist.length} items");
      }
    } catch (e) {
      print("❌ Error fetching watchlist: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ CHECK if a content ID is in the watchlist
  bool isInWatchlist(String contentId) {
    return watchlist.any((item) {
      final movie = item['movie'];
      if (movie != null && movie is Map) {
        return movie['_id'] == contentId;
      }
      // In some cases movie might be just ID if not populated, but your API seems to return full object
      return movie == contentId;
    });
  }

  /// ➕ ADD TO WATCHLIST
  Future<void> addToWatchlist(String contentId) async {
    try {
      isLoading.value = true;
      final response = await repo.addToWatchlist(contentId);
      
      // Fixed: Checking response existence as 201 response might not have "success: true" key
      if (response != null) {
        CustomSnackbar.show(
          title: "Success",
          message: response['message'] ?? "Added to watchlist",
          isSuccess: true,
        );
        // 🔄 Refresh list immediately
        await getWatchlist();
      }
    } catch (e) {
      print("❌ Add Watchlist Error: $e");
      CustomSnackbar.show(
        title: "Error",
        message: "Failed to add to watchlist",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ❌ REMOVE FROM WATCHLIST
  Future<void> removeFromWatchlist(String watchlistId) async {
    try {
      isLoading.value = true;
      final response = await repo.removeFromWatchlist(watchlistId);

      if (response != null) {
        watchlist.removeWhere((item) => item['_id'] == watchlistId);
        CustomSnackbar.show(
          title: "Removed",
          message: "Removed from watchlist",
        );
      }
    } catch (e) {
      print("❌ Remove Error: $e");
      CustomSnackbar.show(
        title: "Error",
        message: "Failed to remove from watchlist",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔄 TOGGLE WATCHLIST
  Future<void> toggleWatchlist(String contentId) async {
    if (isInWatchlist(contentId)) {
      try {
        final watchlistItem = watchlist.firstWhere((item) {
          final movie = item['movie'];
          if (movie != null && movie is Map) {
            return movie['_id'] == contentId;
          }
          return movie == contentId;
        });
        
        final String? watchlistId = watchlistItem['_id'];
        if (watchlistId != null) {
          await removeFromWatchlist(watchlistId);
        }
      } catch (e) {
        print("Error finding item to remove: $e");
      }
    } else {
      await addToWatchlist(contentId);
    }
  }
}
