import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import '../../app/theme/app_colors.dart';

class PaymentBottomSheet extends StatelessWidget {
  const PaymentBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PremiumController controller = Get.find<PremiumController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              /// 🔥 Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// Title
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Select Payment Method",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(color: Colors.grey),

              /// Payment Methods List
              Expanded(
                child: Obx(() => Stack(
                  children: [
                    ListView(
                      controller: scrollController,
                      children: [
                        _paymentTile(Icons.account_balance_wallet, "UPI", controller),
                        _paymentTile(Icons.credit_card, "Credit / Debit Card", controller),
                        _paymentTile(Icons.account_balance, "Net Banking", controller),
                        _paymentTile(Icons.payments, "Wallet", controller),
                        _paymentTile(Icons.qr_code, "Scan & Pay", controller),
                      ],
                    ),
                    if (controller.isSubscribing.value)
                      const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                  ],
                )),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Payment Tile
  Widget _paymentTile(IconData icon, String title, PremiumController controller) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        if (controller.plans.isNotEmpty) {
          final selectedPlan = controller.plans[controller.selectedPlanIndex.value];
          controller.subscribeToPlan(selectedPlan.id);
        }
      },
    );
  }
}
