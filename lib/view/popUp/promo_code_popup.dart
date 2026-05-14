import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/primium_controller/premium_controller.dart';

class ApplyPromoPopup extends StatefulWidget {
  const ApplyPromoPopup({Key? key}) : super(key: key);

  @override
  State<ApplyPromoPopup> createState() => _ApplyPromoPopupState();
}

class _ApplyPromoPopupState extends State<ApplyPromoPopup> {
  final TextEditingController promoController = TextEditingController();
  final PremiumController controller = Get.find<PremiumController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Obx(() {
            final selectedPlan = controller.plans.isNotEmpty
                ? controller.plans[controller.selectedPlanIndex.value]
                : null;

            if (selectedPlan == null) return const SizedBox.shrink();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔴 Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Apply Promo Code",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: AppColors.white),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Your Plan",
                  style: TextStyle(color: AppColors.grey),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: AppColors.buttonColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedPlan.name ?? "Premium Plan",
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold)),
                          Text("Billed every ${selectedPlan.duration} days",
                              style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "INR ${controller.originalPrice.value.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: controller.isPromoApplied.value ? AppColors.grey : AppColors.buttonColor,
                    fontWeight: FontWeight.bold,
                    decoration: controller.isPromoApplied.value ? TextDecoration.lineThrough : null,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Have a promo code?",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: promoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Enter Code",
                          hintStyle: TextStyle(color: AppColors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.buttonColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                        ),
                        onPressed: controller.isApplyingPromo.value
                            ? null
                            : () => controller.applyPromoCode(promoController.text.trim()),
                        child: controller.isApplyingPromo.value
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text("Apply",
                          style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold
                          ),),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount",
                        style: TextStyle(color: AppColors.white)),
                    Text(
                      "INR ${controller.discountedPrice.value.toStringAsFixed(0)}",
                      style: const TextStyle(
                          color: AppColors.buttonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    onPressed: controller.isSubscribing.value
                        ? null
                        : () => controller.subscribeToPlan(selectedPlan.id!),
                    child: controller.isSubscribing.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Proceed To Pay",
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
