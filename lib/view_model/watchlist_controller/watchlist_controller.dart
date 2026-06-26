import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/watchlist_repo.dart';
import '../../utils/custom_snackbar.dart';
import '../auth_controller/auth_controller.dart';
import '../../view/auth/signInPage.dart';

class WatchlistController extends GetxController {
  final WatchlistRepo repo = WatchlistRepo(apiProvider: Get.find<BaseApiService>());

  var isLoading = false.obs;
  var watchlist = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Auth status check
    final authController = Get.find<AuthController>();
    
    // Initial fetch if logged in
    if (authController.isLoggedIn.value) {
      getWatchlist();
    }

    // Listen to login status changes
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
      final contentItem = item['item'];
      if (contentItem != null && contentItem is Map) {
        return contentItem['_id'] == contentId;
      }
      return contentItem == contentId;
    });
  }

  /// ➕ ADD TO WATCHLIST
  Future<void> addToWatchlist(String contentId) async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      Get.toNamed(AppRoutes.signIn);
      return;
    }

    try {
      isLoading.value = true;
      final response = await repo.addToWatchlist(contentId);
      
      if (response != null) {
        CustomSnackbar.show(
          title: "Success",
          message: response['message'] ?? "Added to watchlist ❤️",
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
          isSuccess: true,
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
    if (isLoading.value) return;

    if (isInWatchlist(contentId)) {
      try {
        final watchlistItem = watchlist.firstWhere((item) {
          final contentItem = item['item'];
          if (contentItem != null && contentItem is Map) {
            return contentItem['_id'] == contentId;
          }
          return contentItem == contentId;
        });
        
        final String? watchlistId = watchlistItem['_id'];
        if (watchlistId != null) {
          await removeFromWatchlist(watchlistId);
        }
      } catch (e) {
        print("Error finding item to remove: $e");
        // If not found in list but isInWatchlist was true, maybe refresh
        await getWatchlist();
      }
    } else {
      await addToWatchlist(contentId);
    }
  }
}
