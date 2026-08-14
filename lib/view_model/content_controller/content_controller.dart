import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/interaction_repository.dart';
import '../../data/network/api_network_service.dart';

class ContentController extends GetxController {
  final ContentRepository _repository = ContentRepository(NetworkApiService());
  final InteractionRepository _interactionRepo = InteractionRepository(
    NetworkApiService(),
  );

  var isLoading = true.obs;
  var allContent = <ContentModel>[].obs;
  var allWebBannerContent = <ContentModel>[].obs;
  var trendingContent = <ContentModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var seriesEpisodes = <ContentModel>[].obs;
  var isEpisodesLoading = false.obs;
  var webSections = <WebSectionModel>[].obs;

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

      // Fetch categories first or in parallel
      final cats = await _repository.getCategories();
      cats.sort((a, b) => a.priority.compareTo(b.priority));
      categories.assignAll(cats);

      //  bool isDesktop = Responsive.isDesktop(context);

      final content = await _repository.getAllContent();

      // Filter: Hide content if isHide is true, and filter 18+ content on web
      final filteredContent = content.where((c) {
        if (c.isHide) return false;
        if (kIsWeb && (c.is18Plus)) return false;
        return true;
      }).toList();

      // Sort content by priority (lower number = higher priority, e.g. 1 is top)
      filteredContent.sort(
        (a, b) => (a.priority ?? 999).compareTo(b.priority ?? 999),
      );

      allContent.assignAll(filteredContent);

      // Filter trending for slider
      trendingContent.assignAll(
        filteredContent
            .where(
              (c) => c.category.contains('trending') && c.isComingSoon == false,
            )
            .toList(),
      );

      // Fetch stats for each item to enable sorting by likes

      // -----------------------------
      // web banner content
      //-------------------------------------------------

      final webBannerContent = await _repository.getAllWebSiteBannerContent();
      // Sort web banners by priority
      webBannerContent.sort(
        (a, b) => (a.priority ?? 999).compareTo(b.priority ?? 999),
      );
      allWebBannerContent.assignAll(webBannerContent);

      final sections = await _repository.getWebSections();
      // Sort items within each section by priority
      for (var section in sections) {
        section.items.sort(
          (a, b) => (a.priority ?? 999).compareTo(b.priority ?? 999),
        );
      }
      webSections.assignAll(sections);

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
      // Filter: Hide episodes if isHide is true, and filter 18+ content on web
      final filteredEpisodes = episodes.where((e) {
        if (e.isHide) return false;
        if (kIsWeb && (e.is18Plus)) return false;
        return true;
      }).toList();
      seriesEpisodes.assignAll(filteredEpisodes);
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
