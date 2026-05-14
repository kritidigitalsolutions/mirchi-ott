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
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
                        onPressed: () {
                          if (Get.key.currentState?.canPop() ?? false) {
                            Get.back(); // ✅ If opened via Get.to()
                          } else {
                            Get.find<HomeController>().selectedIndex.value = 0; // ✅ If opened via navbar
                          }
                        }
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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

              ///  Custom Plan Buttons
              if (controller.plans.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(controller.plans.length, (index) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 10,
                          child: _buildPlanButton(controller, controller.plans[index].name, index),
                        );
                      }),
                    ),
                  ),
                ),

              /// 🔹 Plans According To Selection
              Expanded(
                child: controller.plans.isEmpty
                    ? const Center(child: Text("No plans available", style: TextStyle(color: Colors.white)))
                    : _buildPlanList(controller),
              ),

              /// 🔴 Sign In / Purchase / Already Purchased Button
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(() {
                    if (controller.isSubscribing.value) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
                    }

                    final bool hasActive = controller.hasActiveSubscription;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasActive ? Colors.grey : AppColors.buttonColor,
                      ),
                      onPressed: () {
                        if (!controller.isUserLoggedIn.value) {
                          Get.to(() => const SignInPage());
                          return;
                        }

                        if (hasActive) {
                          CustomSnackbar.show(title: "Info", message: "Already Purchased");
                        } else {
                          if (controller.plans.isNotEmpty) {
                            final selectedPlan = controller.plans[controller.selectedPlanIndex.value];
                            controller.subscribeToPlan(selectedPlan.id!);
                          }
                        }
                      },
                      child: Text(
                        hasActive
                            ? "Already Purchased"
                            : (controller.isUserLoggedIn.value
                                ? "Continue with ${controller.selectedPrice.value}"
                                : "Sign In"),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
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

  /// 🔴 Plan Button UI
  Widget _buildPlanButton(PremiumController controller, String text, int index) {
    return Obx(() {
      bool isSelected = controller.selectedPlanIndex.value == index;
      return GestureDetector(
        onTap: () {
          controller.selectPlan(index);
        },
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.buttonColor : Colors.grey[850],
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

  /// 🔹 Plan List
  Widget _buildPlanList(PremiumController controller) {
    return Obx(() {
      if (controller.plans.isEmpty) return const SizedBox.shrink();

      final selectedPlan = controller.plans[controller.selectedPlanIndex.value];

      return ListView(
        padding: const EdgeInsets.all(15),
        children: [
          ExpandablePlanCard(
            title: selectedPlan.name,
            price: "₹${selectedPlan.price}",
            duration: "/ ${selectedPlan.duration} Days",
            features: selectedPlan.features,
          ),
        ],
      );
    });
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
