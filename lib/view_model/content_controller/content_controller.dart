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

  // New storage for category-wise content
  var categoryContents = <String, List<ContentModel>>{}.obs;
  var homeBannerContent = <ContentModel>[].obs;

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

      // 1. Fetch categories
      var cats = await _repository.getCategories();
      
      // 2. Sort categories by priority
      cats.sort((a, b) => a.priority.compareTo(b.priority));

      // 3. Special handling for "home banners" - ensure it's first
      int homeBannerIndex = cats.indexWhere((c) => c.slug == 'home-banners');
      CategoryModel? homeBannerCat;
      if (homeBannerIndex != -1) {
        homeBannerCat = cats.removeAt(homeBannerIndex);
        cats.insert(0, homeBannerCat);
      }
      
      categories.assignAll(cats);

      // 4. Fetch content for each category
      // We do this in parallel to be faster
      final List<Future<void>> fetchTasks = [];
      
      for (var cat in cats) {
        fetchTasks.add(_fetchCategoryContent(cat));
      }

      await Future.wait(fetchTasks);

      // 5. Aggregate all unique content into allContent for search and related content
      final Map<String, ContentModel> uniqueContent = {};
      final Map<String, Set<String>> itemCategories = {};

      categoryContents.forEach((catId, items) {
        for (var item in items) {
          uniqueContent[item.id] = item;
          itemCategories.putIfAbsent(item.id, () => {}).addAll(item.category);
        }
      });

      allContent.assignAll(uniqueContent.values.map((item) {
        final mergedCategories = itemCategories[item.id]?.toList() ?? item.category;
        
        // Seed likes cache if not already set or if fresh data available
        if (item.likes > 0) {
          contentLikes[item.id] = item.likes;
        }
        
        return item.copyWith(category: mergedCategories);
      }).toList());

      // Web sections (keeping existing logic for web if needed)
      if (kIsWeb) {
        final sections = await _repository.getWebSections();
        for (var section in sections) {
          section.items.sort((a, b) {
            if (a.position != null && b.position != null) {
              return a.position!.compareTo(b.position!);
            } else if (a.position != null) {
              return -1;
            } else if (b.position != null) {
              return 1;
            }
            return (a.priority ?? 999).compareTo(b.priority ?? 999);
          });
        }
        webSections.assignAll(sections);
        
        final webBannerContent = await _repository.getAllWebSiteBannerContent();
        webBannerContent.sort((a, b) {
          if (a.position != null && b.position != null) {
            return a.position!.compareTo(b.position!);
          } else if (a.position != null) {
            return -1;
          } else if (b.position != null) {
            return 1;
          }
          return (a.priority ?? 999).compareTo(b.priority ?? 999);
        });
        allWebBannerContent.assignAll(webBannerContent);
      }

    } catch (e) {
      print("Error in ContentController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCategoryContent(CategoryModel category) async {
    try {
      final content = await _repository.getContentByCategory(category.id);
      
      // Filter and sort content
      final filteredContent = content.where((c) {
        if (c.isHide || !c.isPublished) return false;
        if (kIsWeb && (c.is18Plus)) return false;
        return true;
      }).toList();

      filteredContent.sort((a, b) {
        if (a.position != null && b.position != null) {
          return a.position!.compareTo(b.position!);
        } else if (a.position != null) {
          return -1;
        } else if (b.position != null) {
          return 1;
        }
        return (a.priority ?? 999).compareTo(b.priority ?? 999);
      });

      categoryContents[category.id] = filteredContent;

      // If this is the home-banners category, also update the specific observable
      if (category.slug == 'home-banners') {
        homeBannerContent.assignAll(filteredContent);
      }
      
      // Also update trending for legacy compatibility if needed
      if (category.slug == 'trending') {
        trendingContent.assignAll(filteredContent);
      }

    } catch (e) {
      print("Error fetching content for category ${category.name}: $e");
    }
  }

  Future<void> fetchEpisodes(String seriesId) async {
    try {
      isEpisodesLoading.value = true;
      seriesEpisodes.clear();
      final episodes = await _repository.getEpisodes(seriesId);
      // Filter: Hide episodes if isHide is true or isPublished is false, and filter 18+ content on web
      final filteredEpisodes = episodes.where((e) {
        if (e.isHide || !e.isPublished) return false;
        if (kIsWeb && (e.is18Plus)) return false;
        return true;
      }).toList();

      filteredEpisodes.sort((a, b) {
        if (a.episodeNumber != null && b.episodeNumber != null) {
          return a.episodeNumber!.compareTo(b.episodeNumber!);
        }
        if (a.position != null && b.position != null) {
          return a.position!.compareTo(b.position!);
        }
        return (a.priority ?? 999).compareTo(b.priority ?? 999);
      });

      seriesEpisodes.assignAll(filteredEpisodes);
    } catch (e) {
      print("Error fetching episodes: $e");
    } finally {
      isEpisodesLoading.value = false;
    }
  }

  Future<void> fetchSingleStats(String contentId) async {
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
