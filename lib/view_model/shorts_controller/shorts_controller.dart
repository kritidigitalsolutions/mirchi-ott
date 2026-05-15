import 'package:get/get.dart';
import 'package:mirchi_ott/data/models/shorts_model.dart';
import 'package:mirchi_ott/data/network/base_api_service.dart';
import 'package:mirchi_ott/utils/constants.dart';

class ShortsController extends GetxController {
  final BaseApiService apiService = Get.find<BaseApiService>();

  var shortDramas = <ShortDrama>[].obs;
  var isLoading = false.obs;
  var episodesMap = <String, List<ShortEpisode>>{}.obs;
  var isLoadingEpisodes = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShortDramas();
  }

  Future<void> fetchShortDramas() async {
    isLoading.value = true;
    try {
      final response = await apiService.getApi(AppConstants.getShortDramas);
      if (response != null && response['success'] == true) {
        final List<dynamic> dramasJson = response['dramas'];
        shortDramas.value = dramasJson.map((json) => ShortDrama.fromJson(json)).toList();
      }
    } catch (e) {
      print("❌ Error fetching short dramas: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ShortEpisode>> fetchEpisodes(String dramaId) async {
    if (episodesMap.containsKey(dramaId)) {
      return episodesMap[dramaId]!;
    }

    isLoadingEpisodes[dramaId] = true;
    try {
      final response = await apiService.getApi(AppConstants.getShortEpisodes(dramaId));
      if (response != null && response['success'] == true) {
        final List<dynamic> episodesJson = response['episodes'];
        final episodes = episodesJson.map((json) => ShortEpisode.fromJson(json)).toList();
        episodesMap[dramaId] = episodes;
        return episodes;
      }
      return [];
    } catch (e) {
      print("❌ Error fetching episodes for $dramaId: $e");
      return [];
    } finally {
      isLoadingEpisodes[dramaId] = false;
    }
  }
}
