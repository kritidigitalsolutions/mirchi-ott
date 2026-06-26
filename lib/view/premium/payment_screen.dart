import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import '../../app/theme/app_colors.dart';
import '../../data/network/api_network_service.dart';
import '../../data/network/base_api_service.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../utils/app_session.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final PremiumController premiumController;
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    premiumController = Get.isRegistered<PremiumController>() 
        ? Get.find<PremiumController>() 
        : Get.put(PremiumController());
    
    if (kIsWeb) {
      _handleParams();
    }
  }

  void _handleParams() async {
    String? token = Get.parameters['token'];
    final String? planId = Get.parameters['planId'];
    final String? promoCode = Get.parameters['promoCode'];

    // Handle Auto-Login if token is present
    if (token != null && token.isNotEmpty) {
      // Clean token (handle URL encoding, spaces, and "Bearer" prefix)
      token = Uri.decodeComponent(token).trim();
      if (token.startsWith("Bearer ")) {
        token = token.replaceFirst("Bearer ", "");
      }
      
      debugPrint("🌐 Web Auto-Login: Token found in URL");
      await AppSession.setToken(token);
      
      // Update the token in the controller and network service immediately
      authController.isLoggedIn.value = true;
      await AppSession.setLogin(true);
      
      final apiService = Get.find<BaseApiService>();
      if (apiService is NetworkApiService) {
        apiService.setToken(token);
      }

      await authController.getProfile();
    }

    // Ensure plans are loaded
    if (premiumController.plans.isEmpty) {
      await premiumController.fetchPlans();
    }

    // Select the plan from parameters
    if (planId != null) {
      _selectPlanFromParams(planId, promoCode);
    }
  }

  void _selectPlanFromParams(String planId, String? promoCode) {
    int index = premiumController.plans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      premiumController.selectPlan(index);
      if (promoCode != null && promoCode.isNotEmpty) {
        premiumController.applyPromoCode(promoCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("Secure Payment", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (premiumController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final plan = premiumController.plans.isNotEmpty && 
                     premiumController.selectedPlanIndex.value < premiumController.plans.length
            ? premiumController.plans[premiumController.selectedPlanIndex.value]
            : null;

        if (plan == null) {
          return const Center(
            child: Text("No plan selected or available.\nPlease go back and select a plan.", 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16)));
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Duration: ${plan.duration} Days", style: const TextStyle(color: Colors.white70)),
                    const Divider(color: Colors.white24, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount", style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text(premiumController.selectedPrice.value, 
                            style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text("Payment Method", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // SabPaisa Option
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                    const SizedBox(width: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("SabPaisa Gateway", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        Text("UPI, Cards, NetBanking", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.radio_button_checked, color: AppColors.primary),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: premiumController.isSubscribing.value ? null : () => _processPayment(plan.id!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: premiumController.isSubscribing.value
                      ? const SizedBox(
                          height: 25, 
                          width: 25, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("PROCEED TO PAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text("Secure payment powered by SabPaisa", 
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  void _processPayment(String planId) {
    if (kIsWeb) {
      // In web app, call the API to get SabPaisa payment URL
      premiumController.initiateSabPaisaWebPayment(planId);
    } else {
      // In mobile app, redirect to this web page (redundant here but kept for consistency)
      premiumController.startSabPaisaPayment(planId);
    }
  }
}
