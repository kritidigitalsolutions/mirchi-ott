import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/response_model/plan_response/plan_model.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/premium_repository.dart';
import '../../utils/app_session.dart';
import '../../utils/constants.dart';
import '../../utils/custom_snackbar.dart';
import '../auth_controller/auth_controller.dart';

class PremiumController extends GetxController {
  late final PremiumRepository _repository;
  final AuthController _authController = Get.find<AuthController>();
  late Razorpay _razorpay;

  var selectedPlanIndex = 0.obs;
  // Use AuthController's isLoggedIn status instead of local copy
  RxBool get isUserLoggedIn => _authController.isLoggedIn;

  var selectedPrice = "0".obs;
  var isLoading = true.obs;
  var isSubscribing = false.obs;
  var isRedeeming = false.obs;
  var isApplyingPromo = false.obs;
  var plans = <PlanModel>[].obs;

  // Promo Code State
  var appliedPromoCode = "".obs;
  var originalPrice = 0.0.obs;
  var discountedPrice = 0.0.obs;
  var isPromoApplied = false.obs;

  // Subscription Status Data
  var subscriptionData = Rxn<Map<String, dynamic>>();
  var isLoadingStatus = false.obs;

  // ✅ Helper to check if ANY plan is active
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

    // Fetch plans and subscription status
    fetchPlans();

    // Fetch status if logged in
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
      originalPrice.value = (plans[index].price ?? 0).toDouble();
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

  /// 🔹 Start Payment Process (Triggered when user clicks Continue)
  Future<void> startPayment(String planId) async {
    // ✅ Check if already has an active plan
    if (hasActiveSubscription) {
      CustomSnackbar.show(title: "Info", message: "Already Purchased");
      return;
    }

    try {
      // ✅ Close bottom sheet if open before starting payment
      if (Get.isBottomSheetOpen == true) Get.back();

      isSubscribing.value = true;
      final apiService = Get.find<BaseApiService>();
      
      // Prepare request body with promo code if applied
      Map<String, dynamic> body = {"planId": planId};
      if (isPromoApplied.value) {
        body["promoCode"] = appliedPromoCode.value;
      }

      // 1. Create Order on Backend
      final response = await apiService.postApi(
        AppConstants.createOrder,
        body,
      );

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
      String errorMsg = e.toString();
      if (errorMsg.contains("already has an active subscription") || errorMsg.contains("already purchased")) {
         CustomSnackbar.show(title: "Info", message: "Already Purchased");
      } else {
        CustomSnackbar.show(title: "Payment Failed", message: "Something went wrong", isError: true);
      }
    } finally {
      isSubscribing.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      isSubscribing.value = true;
      final apiService = Get.find<BaseApiService>();
      
      final String planId = plans[selectedPlanIndex.value].id ?? "";

      // 2. Verify Payment on Backend
      final verifyResponse = await apiService.postApi(
        AppConstants.verifyPayment,
        {
          "razorpay_order_id": response.orderId,
          "razorpay_payment_id": response.paymentId,
          "razorpay_signature": response.signature,
          "planId": planId
        },
      );

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

  /// 🔹 Apply Code Logic
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

        // Check if it's a Voucher/Flat discount or a Percentage Promo
        if (code.contains("VOUCH") || code.contains("FLAT")) {
          // ➖ VOUCHER: Implement "-" Flat Calculations
          discountedPrice.value = originalPrice.value - numericValue;
          if (discountedPrice.value < 0) discountedPrice.value = 0;

          CustomSnackbar.show(title: "Success", message: "Voucher applied: ₹$numericValue Flat Off!", isSuccess: true);
        } else {
          // 🏷️ PROMO CODE: Implement "%" Percentage Calculations
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

    // If it's a paid plan, use Razorpay. If price is 0 (after promo), use old logic.
    if (discountedPrice.value > 0) {
      startPayment(planId);
    } else {

      try {
        isSubscribing.value = true;
        final response = await _repository.subscribeToPlan(planId, promoCode: promoCode ?? (isPromoApplied.value ? appliedPromoCode.value : null));

        if (response != null && response['success'] == true) {
          CustomSnackbar.show(title: "Success", message: "Payment Success", isSuccess: true);
          fetchSubscriptionStatus();
        }
      } catch (e) {
        String errorMsg = e.toString();
        if (errorMsg.contains("already has an active subscription") || errorMsg.contains("already purchased")) {
          CustomSnackbar.show(title: "Info", message: "Already Purchased");
        } else {
          CustomSnackbar.show(title: "Payment Failed", message: "Something went wrong", isError: true);
        }
      } finally {
        isSubscribing.value = false;
      }
    }
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

  void _showStatusDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(icon, color: iconColor, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Get.back(),
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
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
