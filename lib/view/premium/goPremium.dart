import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/app_session.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../widgets/expendable_plan_card.dart';
import '../auth/signInPage.dart';
import '../popUp/promo_code_popup.dart';
import '../popUp/redeem_voucher_page.dart';
import '../../utils/custom_snackbar.dart';

class GoPremiumPage extends StatefulWidget {
  const GoPremiumPage({super.key});

  @override
  State<GoPremiumPage> createState() => _GoPremiumPageState();
}

class _GoPremiumPageState extends State<GoPremiumPage> {
  late final PremiumController controller;
  bool _isProcessingParams = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PremiumController>()
        ? Get.find<PremiumController>()
        : Get.put(PremiumController());

    if (kIsWeb) {
      _handleWebParams();
    }
  }

  void _handleWebParams() async {
    if (_isProcessingParams) return;
    _isProcessingParams = true;

    final String? token = Get.parameters['token'];
    final String? planId = Get.parameters['planId'];
    final String? promoCode = Get.parameters['promoCode'];
    final String? source = Get.parameters['source'];

    // SabPaisa return parameters
    final String? merchantTxnId = Get.parameters['merchantTxnId'];
    final String? paymentId = Get.parameters['paymentId'];
    final String? checksum = Get.parameters['checksum'];

    // Handle Payment Verification if coming back from SabPaisa
    if (merchantTxnId != null && paymentId != null && planId != null) {
      debugPrint("💳 Web Payment Return detected: $paymentId");
      controller.verifyWebPayment(
        merchantTxnId: merchantTxnId,
        paymentId: paymentId,
        checksum: checksum,
        planId: planId,
      );
    }

    if (token != null && token.isNotEmpty) {
      debugPrint("🌐 Web Auto-Login: Token found in URL");
      
      final AuthController authController = Get.find<AuthController>();
      bool loginSuccess = await authController.websiteLogin(token);

      if (loginSuccess && planId != null) {
        // Wait for plans to load if necessary
        if (controller.plans.isEmpty) {
          await controller.fetchPlans();
        }
        await _selectAndApply(planId, promoCode);

        // Auto-initiate payment if redirected from mobile app
        if (source == 'app' && merchantTxnId == null) {
          debugPrint("🚀 Auto-initiating SabPaisa payment from GoPremiumPage");
          Future.delayed(const Duration(milliseconds: 500), () {
            controller.initiateSabPaisaWebPayment(planId);
          });
        }
      } else if (!loginSuccess) {
        CustomSnackbar.show(title: "Error", message: "Login failed or token expired", isError: true);
      }
    }
  }

  Future<void> _selectAndApply(String planId, String? promoCode) async {
    int index = controller.plans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      controller.selectPlan(index);
      if (promoCode != null && promoCode.isNotEmpty) {
        await controller.applyPromoCode(promoCode);
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
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: const Text(
          "Premium Plans",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.stars, color: Colors.amber, size: 60),
                    const SizedBox(height: 10),
                    const Text(
                      "Unlock Premium Content",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Choose a plan that works for you",
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    _buildFeaturesList(),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Obx(() {
                        if (controller.plans.isEmpty) {
                          return const Center(
                            child: Text("No plans available", 
                            style: TextStyle(color: Colors.white)));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.plans.length,
                          itemBuilder: (context, index) {
                            final plan = controller.plans[index];
                            return Obx(() => ExpandablePlanCard(
                              title: plan.name,
                              price: "₹${plan.price}",
                              duration: "/ ${plan.duration} Days",
                              features: plan.features,
                              isHighlighted: controller.selectedPlanIndex.value == index,
                              onSelect: () => controller.selectPlan(index),
                              onBuy: () {
                                controller.selectPlan(index);
                                if (!controller.isUserLoggedIn.value) {
                                  Get.toNamed(AppRoutes.signIn);
                                } else if (controller.hasActiveSubscription) {
                                  CustomSnackbar.show(title: "Info", message: "Already Purchased");
                                } else {
                                  controller.subscribeToPlan(plan.id!);
                                }
                              },
                            ));
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        );
      }),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _featureRow(Icons.hd_outlined, "High Quality Videos"),
          _featureRow(Icons.ad_units_outlined, "Ad Free Experience"),
          _featureRow(Icons.download_for_offline_outlined, "Affordable Packs"),
          _featureRow(Icons.devices_other, "New Releases"),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                if (controller.isUserLoggedIn.value) {
                  Get.dialog(const ApplyPromoPopup());
                } else {
                  _showSignInPopup();
                }
              },
              icon: const Icon(Icons.local_offer_outlined, color: AppColors.primary),
              label: const Text("Promo Code", style: TextStyle(color: Colors.white)),
            ),
          ),
          Container(height: 30, width: 1, color: Colors.white10),
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                if (controller.isUserLoggedIn.value) {
                  Get.toNamed(AppRoutes.redeemVoucher);
                } else {
                  _showSignInPopup();
                }
              },
              icon: const Icon(Icons.confirmation_num_outlined, color: AppColors.primary),
              label: const Text("Redeem Code", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignInPopup() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Sign In Required", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Please sign in to complete the payment.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.signIn);
            },
            child: const Text("Sign In", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
