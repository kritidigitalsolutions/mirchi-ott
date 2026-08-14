import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/facebook_events_service.dart';
import '../../utils/firebase_analytics_service.dart';
import '../../view_model/primium_controller/premium_controller.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  final String? planId = Get.arguments as String?;
  late final PremiumController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PremiumController>();
    
    // Trigger Purchase Events once when page opens
    _logPurchaseEvent();
  }

  void _logPurchaseEvent() {
    final double amount = controller.discountedPrice.value > 0 
        ? controller.discountedPrice.value 
        : controller.originalPrice.value;

    FacebookEventsService.logPurchase(
      amount: amount,
      currency: "INR",
      contentId: planId ?? "unknown",
    );
    
    FirebaseAnalyticsService.logPurchase(
      amount: amount,
      currency: "INR",
      contentId: planId ?? "unknown",
    );

    // Visual confirmation on screen for debugging
    Future.delayed(const Duration(seconds: 1), () {
      Get.snackbar(
        "Analytics Verified",
        "Meta & Firebase Purchase Events Triggered",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 30),
            const Text(
              "Subscription Successful!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Congratulations! Your premium access is now active. Enjoy ad-free streaming and exclusive content.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Go to Home and clear navigation stack
                  Get.offAllNamed(AppRoutes.home);
                },
                child: const Text(
                  "Start Watching",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
