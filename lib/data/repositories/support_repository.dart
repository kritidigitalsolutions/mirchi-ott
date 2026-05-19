import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class SupportRepository {
  final BaseApiService _apiService;

  SupportRepository(this._apiService);

  Future<dynamic> createTicket(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postApi(AppConstants.createTicket, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTickets() async {
    try {
      final response = await _apiService.getApi(AppConstants.getTickets);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> replyTicket(String id, String message) async {
    try {
      final response = await _apiService.postApi(AppConstants.replyTicket(id), {'message': message});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTicketMessages(String id) async {
    try {
      final response = await _apiService.getApi(AppConstants.getConversation(id));
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
