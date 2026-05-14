import '../models/response_model/content_response_model/content_model.dart';
import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class ContentRepository {
  final BaseApiService apiProvider;

  ContentRepository(this.apiProvider);

  Future<List<ContentModel>> getAllContent() async {
    try {
      final response = await apiProvider.getApi(AppConstants.baseUrl + '/content');
      if (response['success'] == true) {
        List<dynamic> data = response['data'];
        return data.map((item) => ContentModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching content: $e");
      rethrow;
    }
  }
}
