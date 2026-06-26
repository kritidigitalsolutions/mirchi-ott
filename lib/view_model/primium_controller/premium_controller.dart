import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/response_model/plan_response/plan_model.dart';
import '../../data/network/base_api_service.dart';
import '../../data/repositories/premium_repository.dart';
import '../../utils/constants.dart';
import '../../utils/app_session.dart';
import '../../utils/custom_snackbar.dart';
import '../auth_controller/auth_controller.dart';

class PremiumController extends GetxController with WidgetsBindingObserver {
  late final PremiumRepository _repository;
  final AuthController _authController = Get.find<AuthController>();

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
    WidgetsBinding.instance.addObserver(this);
    _repository = PremiumRepository(Get.find<BaseApiService>());

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
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh subscription status when user returns to app after payment
      if (isUserLoggedIn.value) {
        fetchSubscriptionStatus();
      }
    }
  }

  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      final response = await _repository.getPlans();
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['plans'];
        plans.assignAll(data.map((e) => PlanModel.fromJson(e)).toList());
        
        if (plans.isNotEmpty) {
          // If on web, check if a plan is requested via URL parameters
          String? targetPlanId = kIsWeb ? Get.parameters['planId'] : null;
          int index = -1;
          if (targetPlanId != null && targetPlanId.isNotEmpty) {
            index = plans.indexWhere((p) => p.id == targetPlanId);
          }

          if (index != -1) {
            selectPlan(index);
            String? promo = Get.parameters['promoCode'];
            if (promo != null && promo.isNotEmpty) {
              applyPromoCode(promo);
            }
          } else {
            selectPlan(0);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching plans: $e");
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
    subscribeToPlan(planId);
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
              if (kIsWeb) {
                initiateSabPaisaWebPayment(planId);
              } else {
                startSabPaisaPayment(planId);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> initiateSabPaisaWebPayment(String planId) async {
    try {
      if (planId.isEmpty) {
        CustomSnackbar.show(title: "Error", message: "Plan ID is missing", isError: true);
        return;
      }
      
      isSubscribing.value = true;
      final apiService = Get.find<BaseApiService>();

      Map<String, dynamic> body = {"planId": planId};
      if (isPromoApplied.value && appliedPromoCode.value.isNotEmpty) {
        body["promoCode"] = appliedPromoCode.value;
      }
      body["paymentMethod"] = "sabpaisa";

      debugPrint("🔗 Creating Order for Web: $body");
      final response = await apiService.postApi(AppConstants.createOrder, body);

      if (response != null && response['success'] == true) {
        String? paymentUrl = response['checkoutUrl'] ?? response['paymentUrl'] ?? response['url'];

        if (paymentUrl != null) {
          debugPrint("🚀 Redirecting to SabPaisa: $paymentUrl");
          
          final Uri uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            // Fallback for some browsers
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        } else {
          CustomSnackbar.show(title: "Error", message: "Payment gateway URL not found in response", isError: true);
        }
      } else {
        CustomSnackbar.show(title: "Error", message: response?['message'] ?? "Failed to create order", isError: true);
      }
    } catch (e) {
      debugPrint("❌ SabPaisa Web Error: $e");
      String errorMessage = "Something went wrong starting payment";
      if (e.toString().contains("Unauthorized")) {
        errorMessage = "Session expired or invalid. Please login again.";
      } else if (e.toString().contains("FetchDataException")) {
        errorMessage = "Network error. Please check your connection.";
      }
      CustomSnackbar.show(title: "Error", message: "$errorMessage: $e", isError: true);
    } finally {
      isSubscribing.value = false;
    }
  }

  Future<void> startSabPaisaPayment(String planId) async {
    try {
      final token = AppSession.getToken() ?? "";
      
      // Using the real production web link
      String baseUrl = "https://mirchiapp.in";
      
      // Redirect to GoPremium page with token and plan details
      final Uri uri = Uri.parse("$baseUrl/goPremium").replace(queryParameters: {
        'token': token,
        'planId': planId,
        'promoCode': isPromoApplied.value ? appliedPromoCode.value : "",
        'source': 'app', // Tells web app this came from mobile
      });

      debugPrint("🚀 Redirecting to Web: $uri");

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackbar.show(title: "Error", message: "Could not open website", isError: true);
      }
    } catch (e) {
      debugPrint("❌ Redirection Error: $e");
      CustomSnackbar.show(title: "Error", message: "Something went wrong", isError: true);
    }
  }

  Future<void> verifyWebPayment({
    required String merchantTxnId,
    required String paymentId,
    required String planId,
    String? checksum,
  }) async {
    try {
      isLoading.value = true;
      final apiService = Get.find<BaseApiService>();
      final verifyResponse = await apiService.postApi(AppConstants.verifyPayment, {
        "merchantTxnId": merchantTxnId,
        "paymentId": paymentId,
        "checksum": checksum ?? "",
        "planId": planId,
      });

      if (verifyResponse != null && verifyResponse['success'] == true) {
        CustomSnackbar.show(title: "Success", message: "Payment Verified Successfully!", isSuccess: true);
        fetchSubscriptionStatus();
      } else {
        CustomSnackbar.show(title: "Payment Failed", message: verifyResponse['message'] ?? "Verification failed", isError: true);
      }
    } catch (e) {
      debugPrint("❌ Verification Error: $e");
      CustomSnackbar.show(title: "Error", message: "Failed to verify payment", isError: true);
    } finally {
      isLoading.value = false;
    }
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
