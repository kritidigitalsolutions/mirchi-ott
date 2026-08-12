import '../network/base_api_service.dart';
import '../../utils/constants.dart';

class PremiumRepository {
  final BaseApiService apiProvider;

  PremiumRepository(this.apiProvider);

  Future<dynamic> getPlans() async {
    try {
      final response = await apiProvider.getApi(AppConstants.planList);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> subscribeToPlan(String planId, {String? promoCode}) async {
    try {
      final Map<String, dynamic> data = {"planId": planId};
      if (promoCode != null && promoCode.isNotEmpty) {
        data["promoCode"] = promoCode;
      }
      final response = await apiProvider.postApi(
        AppConstants.buyPlan,
        data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getSubscriptionStatus() async {
    try {
      final response = await apiProvider.getApi(AppConstants.planCheck);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> redeemVoucher(String code) async {
    try {
      final response = await apiProvider.postApi(
        AppConstants.redeemVoucher,
        {"code": code},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
