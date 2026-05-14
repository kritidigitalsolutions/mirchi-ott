import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../view_model/primium_controller/premium_controller.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final PremiumController premiumController = Get.put(PremiumController());

    // Rx variables for expand/collapse logic
    final loginExpanded = false.obs;
    final subscriptionExpanded = false.obs;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Account Settings",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// LOGIN INFORMATION SECTION
            Obx(() => _buildExpandableSection(
              title: "Login Information",
              isExpanded: loginExpanded.value,
              onTap: () => loginExpanded.toggle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.phone, "Phone", authController.userData.value?['phone'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.email, "Email", authController.userData.value?['email'] ?? 'N/A'),
                ],
              ),
            )),

            const SizedBox(height: 15),

            /// SUBSCRIPTION SECTION (DYNAMIC)
            Obx(() {
              final sub = premiumController.subscriptionData.value;
              final hasActiveSub = sub != null && sub['status'] == 'active';

              return _buildExpandableSection(
                title: "Subscription",
                isExpanded: subscriptionExpanded.value,
                onTap: () => subscriptionExpanded.toggle(),
                child: hasActiveSub ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubscriptionBadge(sub['plan']['name'] ?? 'Premium'),
                    const SizedBox(height: 15),
                    _buildInfoRow(Icons.calendar_today, "Start Date", premiumController.formatDate(sub['startDate'])),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.event_available, "Valid Till", premiumController.formatDate(sub['endDate'])),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.currency_rupee, "Amount Paid", "₹${sub['amount']}"),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.info_outline, "Status", sub['status'].toString().toUpperCase(), color: Colors.green),
                  ],
                ) : const Center(
                  child: Text(
                    "No active subscription found",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// INFO ROW WIDGET
  Widget _buildInfoRow(IconData icon, String label, String value, {Color color = Colors.white}) {
    return Row(
      children: [
        Icon(icon, color: Colors.pinkAccent, size: 18),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// SUBSCRIPTION BADGE
  Widget _buildSubscriptionBadge(String planName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pinkAccent),
      ),
      child: Text(
        planName,
        style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  /// EXPANDABLE SECTION WIDGET
  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isExpanded ? Colors.pinkAccent.withOpacity(0.5) : Colors.transparent),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onTap: onTap,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(width: double.infinity, child: child),
            ),
            crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          )
        ],
      ),
    );
  }
}
