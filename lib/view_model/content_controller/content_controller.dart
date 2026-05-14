import 'package:get/get.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/interaction_repository.dart';
import '../../data/network/api_network_service.dart';

class ContentController extends GetxController {
  final ContentRepository _repository = ContentRepository(NetworkApiService());
  final InteractionRepository _interactionRepo = InteractionRepository(NetworkApiService());

  var isLoading = true.obs;
  var allContent = <ContentModel>[].obs;
  var trendingContent = <ContentModel>[].obs;
  var seriesEpisodes = <ContentModel>[].obs;
  var isEpisodesLoading = false.obs;
  
  // Cache for likes: ContentID -> LikeCount
  var contentLikes = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContent();
  }

  Future<void> fetchContent() async {
    try {
      isLoading.value = true;
      final content = await _repository.getAllContent();
      allContent.assignAll(content);
      
      // Filter trending for slider
      trendingContent.assignAll(content.where((c) => c.category.contains('trending') && c.isComingSoon == false).toList());
      
      // Fetch stats for each item to enable sorting by likes
      _fetchAllStats();
      
    } catch (e) {
      print("Error in ContentController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEpisodes(String seriesId) async {
    try {
      isEpisodesLoading.value = true;
      seriesEpisodes.clear();
      final episodes = await _repository.getEpisodes(seriesId);
      seriesEpisodes.assignAll(episodes);
    } catch (e) {
      print("Error fetching episodes: $e");
    } finally {
      isEpisodesLoading.value = false;
    }
  }

  Future<void> _fetchAllStats() async {
    for (var item in allContent) {
      _fetchSingleStats(item.id);
    }
  }

  Future<void> _fetchSingleStats(String contentId) async {
    try {
      final stats = await _interactionRepo.getInteractionStats(contentId);
      if (stats != null) {
        contentLikes[contentId] = stats['likes'] ?? 0;
      }
    } catch (e) {
      print("Error fetching stats for $contentId: $e");
    }
  }
}
