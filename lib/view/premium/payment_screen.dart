import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import '../../app/theme/app_colors.dart';
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
    _handleAutoLogin();
  }

  void _handleAutoLogin() async {
    if (kIsWeb) {
      final String? token = Get.parameters['token'];
      final String? planId = Get.parameters['planId'];
      final String? promoCode = Get.parameters['promoCode'];

      if (token != null && token.isNotEmpty) {
        debugPrint("🌐 Web Auto-Login: Token found in URL");
        await AppSession.setToken(token);
        authController.setLoginStatus(true);
        await authController.getProfile();
        
        // Wait for plans to be loaded if they are currently fetching
        if (premiumController.plans.isEmpty) {
          ever(premiumController.plans, (plans) {
            if (plans.isNotEmpty && planId != null) {
              _selectPlanFromParams(planId, promoCode);
            }
          });
        } else if (planId != null) {
          _selectPlanFromParams(planId, promoCode);
        }
      }
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
        title: const Text("Secure Payment", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (premiumController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final plan = premiumController.plans.isNotEmpty && premiumController.selectedPlanIndex.value < premiumController.plans.length
            ? premiumController.plans[premiumController.selectedPlanIndex.value]
            : null;

        if (plan == null) {
          return const Center(child: Text("No plan selected", style: TextStyle(color: Colors.white)));
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Duration: ${plan.duration} Days", style: const TextStyle(color: Colors.white70)),
                    const Divider(color: Colors.white24, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount", style: TextStyle(color: Colors.white, fontSize: 16)),
                        Text(premiumController.selectedPrice.value, 
                            style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text("Payment Method", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildPaymentOption(
                title: "SabPaisa (UPI, Cards, NetBanking)",
                icon: Icons.account_balance_wallet,
                onTap: () => _processPayment(plan.id!),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: premiumController.isSubscribing.value ? null : () => _processPayment(plan.id!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: premiumController.isSubscribing.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("PAY NOW", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaymentOption({required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.radio_button_checked, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _processPayment(String planId) {
    if (kIsWeb) {
      // In web app, we call the API to get SabPaisa payment URL
      premiumController.initiateSabPaisaWebPayment(planId);
    } else {
      // In mobile app, we usually redirect to web
      premiumController.startSabPaisaPayment(planId);
    }
  }
}
