import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class SupportRepository {
  final BaseApiService _apiService;

  SupportRepository(this._apiService);

  Future<dynamic> createTicket(Map<String, dynamic> data, {List<String>? filePaths}) async {
    try {
      if (filePaths == null || filePaths.isEmpty) {
        final response = await _apiService.postApi(AppConstants.createTicket, data);
        return response;
      } else {
        // Send all files under the 'attachments' key as a list
        final response = await _apiService.postMultipartApi(
          AppConstants.createTicket, 
          data, 
          {'attachments': filePaths}
        );
        return response;
      }
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
