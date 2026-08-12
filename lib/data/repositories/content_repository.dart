import '../models/category_model.dart';
import '../models/response_model/content_response_model/content_model.dart';
import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class ContentRepository {
  final BaseApiService apiProvider;

  ContentRepository(this.apiProvider);

  Future<List<ContentModel>> getAllContent() async {
    try {
      final response = await apiProvider.getApi(AppConstants.getAllContent);
      if (response['success'] == true) {
        // The API returns the list under the 'content' key
        List<dynamic> data = response['content'] ?? [];
        return data.map((item) => ContentModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching content: $e");
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiProvider.getApi(AppConstants.getCategories);
      if (response['success'] == true) {
        List<dynamic> data = response['data'] ?? [];
        return data.map((item) => CategoryModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching categories: $e");
      rethrow;
    }
  }

  Future<List<ContentModel>> getEpisodes(String seriesId) async {
    try {
      final response = await apiProvider.getApi(AppConstants.getEpisodes(seriesId));
      if (response['success'] == true) {
        List<dynamic> data = response['episodes'] ?? [];
        return data.map((item) => ContentModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching episodes: $e");
      rethrow;
    }
  }
}
