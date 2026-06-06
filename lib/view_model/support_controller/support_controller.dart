import 'package:file_picker/file_picker.dart' as fp;
import 'package:get/get.dart';
import '../../data/repositories/support_repository.dart';
import '../../data/network/base_api_service.dart';
import '../../utils/custom_snackbar.dart';

class SupportController extends GetxController {
  late final SupportRepository _repository;

  var isLoading = false.obs;
  var isMessagesLoading = false.obs;
  var tickets = <dynamic>[].obs;
  var ticketMessages = <dynamic>[].obs;
  var categories = ["PAYMENT", "TECHNICAL", "SUBSCRIPTION", "ACCOUNT", "OTHER"];
  
  var selectedFilePaths = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _repository = SupportRepository(Get.find<BaseApiService>());
    fetchTickets();
  }

  void pickFiles() async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
        allowMultiple: true,
        type: fp.FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        selectedFilePaths.addAll(result.paths.whereType<String>());
      }
    } catch (e) {
      print("Error picking files: $e");
    }
  }

  void removeFile(int index) {
    selectedFilePaths.removeAt(index);
  }

  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;
      final response = await _repository.getTickets();
      if (response != null && response['success'] == true) {
        tickets.assignAll(response['tickets'] ?? []);
      }
    } catch (e) {
      print("Error fetching tickets: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTicketMessages(String ticketId) async {
    try {
      isMessagesLoading.value = true;
      ticketMessages.clear();
      final response = await _repository.getTicketMessages(ticketId);
      if (response != null && response['success'] == true) {
        ticketMessages.assignAll(response['conversation']['messages'] ?? []);
      }
    } catch (e) {
      print("Error fetching messages: $e");
    } finally {
      isMessagesLoading.value = false;
    }
  }

  Future<bool> createTicket(String subject, String message, String category) async {
    try {
      isLoading.value = true;
      final response = await _repository.createTicket({
        "subject": subject,
        "message": message,
        "category": category
      }, filePaths: selectedFilePaths);
      
      if (response != null && response['success'] == true) {
        CustomSnackbar.show(title: "Success", message: "Ticket created successfully", isSuccess: true);
        selectedFilePaths.clear();
        await fetchTickets();
        return true;
      }
      return false;
    } catch (e) {
      CustomSnackbar.show(title: "Error", message: e.toString(), isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> replyToTicket(String ticketId, String message) async {
    try {
      isMessagesLoading.value = true;
      final response = await _repository.replyTicket(ticketId, message);
      if (response != null && response['success'] == true) {
        ticketMessages.assignAll(response['messages'] ?? []);
        fetchTickets();
        return true;
      }
      return false;
    } catch (e) {
      CustomSnackbar.show(title: "Error", message: e.toString(), isError: true);
      return false;
    } finally {
      isMessagesLoading.value = false;
    }
  }
}
