import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/response_model/plan_response/plan_model.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/premium_repository.dart';
import '../../utils/constants.dart';
import '../../utils/custom_snackbar.dart';
import '../auth_controller/auth_controller.dart';

class PremiumController extends GetxController {
  late final PremiumRepository _repository;
  final AuthController _authController = Get.find<AuthController>();
  late Razorpay _razorpay;

  var selectedPlanIndex = 0.obs;
  RxBool get isUserLoggedIn => _authController.isLoggedIn;

  var selectedPrice = "0".obs;
  var isLoading = true.obs;
  var isSubscribing = false.obs;
  var isRedeeming = false.obs;
  var isApplyingPromo = false.obs;
  var plans = <PlanModel>[].obs;

  var appliedPromoCode = "".obs;
  var originalPrice = 0.0.obs;
  var discountedPrice = 0.0.obs;
  var isPromoApplied = false.obs;

  var subscriptionData = Rxn<Map<String, dynamic>>();
  var isLoadingStatus = false.obs;

  bool get hasActiveSubscription => 
      subscriptionData.value != null && subscriptionData.value!['status'] == 'active';

  @override
  void onInit() {
    super.onInit();
    _repository = PremiumRepository(Get.find<BaseApiService>());
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    fetchPlans();

    var demoSub = GetStorage().read('demo_subscription');
    if (demoSub != null) {
      subscriptionData.value = Map<String, dynamic>.from(demoSub);
    }

    ever(isUserLoggedIn, (bool loggedIn) {
      if (loggedIn) {
        fetchSubscriptionStatus();
      } else {
        subscriptionData.value = null;
      }
    });

    if (isUserLoggedIn.value) {
      fetchSubscriptionStatus();
    }
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      final response = await _repository.getPlans();
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['plans'];
        plans.assignAll(data.map((e) => PlanModel.fromJson(e)).toList());
        if (plans.isNotEmpty) {
          selectPlan(0);
        }
      }
    } catch (e) {
      print("Error fetching plans: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
    isPromoApplied.value = false;
    appliedPromoCode.value = "";
    if (index < plans.length) {
      originalPrice.value = (plans[index].price).toDouble();
      discountedPrice.value = originalPrice.value;
      selectedPrice.value = "₹${plans[index].price}";
    }
  }

  Future<void> fetchSubscriptionStatus() async {
    if (!isUserLoggedIn.value) return;
    try {
      isLoadingStatus.value = true;
      final response = await _repository.getSubscriptionStatus();
      if (response != null && response['success'] == true) {
        subscriptionData.value = response['subscription'];
      }
    } catch (e) {
      print("Error fetching subscription status: $e");
    } finally {
      isLoadingStatus.value = false;
    }
  }

  Future<void> startPayment(String planId) async {
    if (hasActiveSubscription) {
      CustomSnackbar.show(title: "Info", message: "Already Purchased");
      return;
    }
    try {
      if (Get.isBottomSheetOpen == true) Get.back();
      isSubscribing.value = true;
      final apiService = Get.find<BaseApiService>();
      Map<String, dynamic> body = {"planId": planId};
      if (isPromoApplied.value) body["promoCode"] = appliedPromoCode.value;

      final response = await apiService.postApi(AppConstants.createOrder, body);
      if (response != null && response['success'] == true) {
        var options = {
          'key': response['key'],
          'amount': response['order']['amount'],
          'name': 'Mirchi OTT',
          'order_id': response['order']['id'],
          'description': 'Subscription Plan',
          'prefill': {
            'contact': _authController.userData.value?['phone'] ?? '',
            'email': _authController.userData.value?['email'] ?? ''
          },
          'notes': {
            'planId': planId,
            'promoCode': isPromoApplied.value ? appliedPromoCode.value : "",
          }
        };
        _razorpay.open(options);
      }
    } catch (e) {
      CustomSnackbar.show(title: "Payment Failed", message: "Something went wrong", isError: true);
    } finally {
      isSubscribing.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      isSubscribing.value = true;
      final apiService = Get.find<BaseApiService>();
      final String planId = plans[selectedPlanIndex.value].id;
      final verifyResponse = await apiService.postApi(AppConstants.verifyPayment, {
        "razorpay_order_id": response.orderId,
        "razorpay_payment_id": response.paymentId,
        "razorpay_signature": response.signature,
        "planId": planId
      });
      if (verifyResponse != null && verifyResponse['success'] == true) {
        CustomSnackbar.show(title: "Success", message: "Payment Success", isSuccess: true);
        fetchSubscriptionStatus();
      }
    } catch (e) {
       CustomSnackbar.show(title: "Payment Failed", message: "Something went wrong", isError: true);
    } finally {
      isSubscribing.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isSubscribing.value = false;
    CustomSnackbar.show(title: "Payment Failed", message: "Payment Failed", isError: true);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomSnackbar.show(title: "External Wallet", message: "Wallet: ${response.walletName}");
  }

  Future<void> applyPromoCode(String promoCode) async {
    if (plans.isEmpty || selectedPlanIndex.value >= plans.length) return;
    try {
      isApplyingPromo.value = true;
      String code = promoCode.toUpperCase();
      final RegExp regExp = RegExp(r'\d+');
      final match = regExp.firstMatch(code);
      if (match != null) {
        double numericValue = double.parse(match.group(0)!);
        isPromoApplied.value = true;
        appliedPromoCode.value = code;
        if (code.contains("VOUCH") || code.contains("FLAT")) {
          discountedPrice.value = originalPrice.value - numericValue;
          if (discountedPrice.value < 0) discountedPrice.value = 0;
          CustomSnackbar.show(title: "Success", message: "Voucher applied: ₹$numericValue Flat Off!", isSuccess: true);
        } else {
          double discountAmount = (originalPrice.value * numericValue) / 100;
          discountedPrice.value = originalPrice.value - discountAmount;
          if (discountedPrice.value < 0) discountedPrice.value = 0;
          CustomSnackbar.show(title: "Success", message: "Promo applied: $numericValue% Discount Off!", isSuccess: true);
        }
        selectedPrice.value = "₹${discountedPrice.value.toStringAsFixed(1)}";
      } else {
        CustomSnackbar.show(title: "Error", message: "Invalid Code Format", isError: true);
      }
    } catch (e) {
      isPromoApplied.value = false;
      appliedPromoCode.value = "";
      discountedPrice.value = originalPrice.value;
      selectedPrice.value = "₹${originalPrice.value}";
    } finally {
      isApplyingPromo.value = false;
    }
  }

  Future<void> subscribeToPlan(String planId, {String? promoCode}) async {
    if (hasActiveSubscription) {
      CustomSnackbar.show(title: "Info", message: "Already Purchased");
      return;
    }
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Purchase Plan", style: TextStyle(color: Colors.white)),
        content: const Text("Do you want to purchase this plan?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _setDemoActiveSubscription(planId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _setDemoActiveSubscription(String planId) {
    subscriptionData.value = {
      'status': 'active',
      'planId': planId,
      'plan': plans.firstWhere((p) => p.id == planId).toJson(),
      'expiryDate': DateTime.now().add(const Duration(days: 30)).toString(),
    };
    GetStorage().write('demo_subscription', subscriptionData.value);
    CustomSnackbar.show(title: "Success", message: "Plan purchased successfully (Demo Mode)", isSuccess: true);
  }

  Future<void> redeemVoucher(String code) async {
    try {
      isRedeeming.value = true;
      final response = await _repository.redeemVoucher(code);
      if (response != null && response['success'] == true) {
        CustomSnackbar.show(title: "Success", message: "Redeemed successfully", isSuccess: true);
        fetchSubscriptionStatus();
      }
    } catch (e) {
      CustomSnackbar.show(title: "Error", message: "Something went wrong", isError: true);
    } finally {
      isRedeeming.value = false;
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "N/A";
    }
  }
}
