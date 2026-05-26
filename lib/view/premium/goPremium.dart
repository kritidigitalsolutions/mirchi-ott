import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/home_controller/home_controller.dart';
import '../../widgets/expendable_plan_card.dart';
import '../auth/signInPage.dart';
import '../popUp/promo_code_popup.dart';
import '../popUp/redeem_voucher_page.dart';
import '../../utils/custom_snackbar.dart';

class GoPremiumPage extends StatelessWidget {
  const GoPremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PremiumController controller = Get.put(PremiumController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return Column(
            children: [
              /// 🔹 Top Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Back Icon
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        if (Get.key.currentState?.canPop() ?? false) {
                          Get.back();
                        } else {
                          Get.find<HomeController>().selectedIndex.value = 0;
                        }
                      },
                    ),

                    /// Header Text
                    const Text(
                      "Plans ",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /// Empty space to balance the row
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // const SizedBox(height: 20),
              const SizedBox(height: 20),

              /// 🔹 Common Features Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [

                    Text(
                      "All Premium Plans Include",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),

                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Ad-Free Streaming Experience",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Unlimited Access to Premium Content",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Watch on Multiple Devices",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "HD & Full HD Streaming Quality",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 🔹 Upgrade Text
              const Text(
                "Upgrade Your Plan for More Benefits",
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// 🔹 Plans List
              Expanded(
                child: Obx(() {
                  if (controller.plans.isEmpty) {
                    return const Center(child: Text("No plans available", style: TextStyle(color: Colors.white)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                            Get.to(() => const SignInPage());
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

              /// 🔹 Bottom 50%-50%
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.isUserLoggedIn.value) {
                          Get.dialog(const ApplyPromoPopup());
                        } else {
                          _showSignInPopup();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.borderColor),
                            right: BorderSide(color: AppColors.borderColor),
                          ),
                        ),
                        child: const Text("Apply Promo Code",
                            style: TextStyle(color: AppColors.white)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.isUserLoggedIn.value) {
                          Get.to(() => RedeemVoucherPage());
                        } else {
                          _showSignInPopup();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.borderColor),
                          ),
                        ),
                        child: const Text("Apply Prepaid Pin",
                            style: TextStyle(color: AppColors.white)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }),
      ),
    );
  }

  /// 🔹 Sign In Required Popup
  void _showSignInPopup() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Sign In Required", style: TextStyle(color: AppColors.white)),
        content: const Text(
          "Please sign in to complete the payment.",
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
            onPressed: () {
              Get.back();
              Get.to(() => const SignInPage());
            },
            child: const Text(
              "Sign In",
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
