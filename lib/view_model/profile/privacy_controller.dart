import 'package:get/get.dart';
import '../../data/providers/privacy_provider.dart';

class PrivacyController extends GetxController {
  var privacyTitle = "".obs;
  var privacyContent = "".obs;
  
  var termsTitle = "".obs;
  var termsContent = "".obs;
  
  var refundTitle = "".obs;
  var refundContent = "".obs;

  var helpData = <dynamic>[].obs;

  var isLoadingPrivacy = true.obs;
  var isLoadingTerms = true.obs;
  var isLoadingRefund = true.obs;
  var isLoadingHelp = true.obs;

  Future<void> fetchPrivacyPolicy() async {
    isLoadingPrivacy.value = true;
    final data = await PrivacyService.getPrivacyPolicy();
    if (data != null) {
      privacyTitle.value = data['document']['title'] ?? "";
      privacyContent.value = data['document']['content'] ?? "";
    }
    isLoadingPrivacy.value = false;
  }

  Future<void> fetchTerms() async {
    isLoadingTerms.value = true;
    final data = await PrivacyService.getTerms();
    if (data != null) {
      termsTitle.value = data['document']['title'] ?? "";
      termsContent.value = data['document']['content'] ?? "";
    }
    isLoadingTerms.value = false;
  }

  Future<void> fetchRefundPolicy() async {
    isLoadingRefund.value = true;
    final data = await PrivacyService.getRefundPolicy();
    if (data != null) {
      refundTitle.value = data['document']['title'] ?? "";
      refundContent.value = data['document']['content'] ?? "";
    }
    isLoadingRefund.value = false;
  }

  Future<void> fetchHelpData() async {
    isLoadingHelp.value = true;
    final data = await PrivacyService.getHelpData();
    helpData.assignAll(data);
    isLoadingHelp.value = false;
  }
}
