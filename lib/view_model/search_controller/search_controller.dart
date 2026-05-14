import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../content_controller/content_controller.dart';

class AppSearchController extends GetxController {
  var searchQuery = "".obs;
  final TextEditingController searchController = TextEditingController();
  
  var searchResults = <ContentModel>[].obs;
  final ContentController _contentController = Get.find<ContentController>();

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
    } else {
      // 1. Filter contents by title
      List<ContentModel> filtered = _contentController.allContent.where((item) {
        return item.title.toLowerCase().contains(query.toLowerCase());
      }).toList();

      // 2. Sort by like counts from ContentController cache
      filtered.sort((a, b) {
        int likesA = _contentController.contentLikes[a.id] ?? 0;
        int likesB = _contentController.contentLikes[b.id] ?? 0;
        return likesB.compareTo(likesA); // Descending (High to Low)
      });

      searchResults.assignAll(filtered);
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = "";
    searchResults.clear();
  }
}
