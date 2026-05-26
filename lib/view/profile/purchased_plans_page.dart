import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/primium_controller/premium_controller.dart';
import '../premium/goPremium.dart';

class PurchasedPlansPage extends StatelessWidget {
  const PurchasedPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PremiumController controller = Get.find<PremiumController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Purchased Plans",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final sub = controller.subscriptionData.value;
        final bool hasActiveSub = sub != null && sub['status'] == 'active';

        if (!hasActiveSub) {
          return _buildNoPlanView();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current Active Plan",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildPlanCard(sub!),
              const SizedBox(height: 30),
              
              const Text(
                "Subscription Details",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildDetailsSection(sub),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Get.to(() => const GoPremiumPage()),
                  child: const Text(
                    "UPGRADE OR RENEW PLAN",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> sub) {
    final plan = sub['plan'] ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan['name'] ?? "Premium Plan",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.verified, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Status: ${sub['status']?.toString().toUpperCase() ?? 'ACTIVE'}",
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                "Expires on: ${Get.find<PremiumController>().formatDate(sub['expiryDate'])}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> sub) {
    final plan = sub['plan'] ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _detailRow("Plan Price", "₹${plan['price'] ?? '0'}"),
          const Divider(color: Colors.white10, height: 30),
          _detailRow("Duration", "${plan['duration'] ?? '0'} Days"),
          const Divider(color: Colors.white10, height: 30),
          _detailRow("Payment Status", "Success"),
          const Divider(color: Colors.white10, height: 30),
          _detailRow("Auto Renewal", "Off"),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNoPlanView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_membership, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "No Active Subscription",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "You haven't purchased any plan yet. Subscribe now to enjoy premium content.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Get.to(() => const GoPremiumPage()),
                child: const Text("VIEW PLANS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
