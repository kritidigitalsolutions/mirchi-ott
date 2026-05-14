import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/view/profile/privacy_policy_page.dart';
import 'package:mirchi_ott/view/profile/setting_page.dart';
import 'package:mirchi_ott/view/profile/terms_condition_page.dart';
import 'package:mirchi_ott/view/profile/watchlist.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../premium/goPremium.dart';
import 'account_setting.dart';
import 'Rate_your_app.dart';
import 'help_page.dart';
import 'refund_policy_page.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final PremiumController premiumController = Get.put(PremiumController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.getProfile();
      if (authController.isLoggedIn.value) {
        premiumController.fetchSubscriptionStatus();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Profile Image from API
                          Obx(() {
                            final user = authController.userData.value;
                            final imageUrl = user?['avatar'] ?? user?['image'] ?? user?['profileImage'];
                            
                            return CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: (imageUrl == null || imageUrl.isEmpty)
                                  ? const Icon(Icons.person, color: AppColors.white, size: 30)
                                  : null,
                            );
                          }),

                          const SizedBox(width: 12),

                          // Name and Phone from API
                          Expanded(
                            child: Obx(() {
                              final user = authController.userData.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?['name'] ?? "User Name",
                                    style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?['phone'] ?? "No Phone",
                                    style: const TextStyle(
                                        color: AppColors.grey, fontSize: 14),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.grey, height: 1),

                    // ---------- DYNAMIC PLAN SECTION ----------
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Obx(() {
                        final sub = premiumController.subscriptionData.value;
                        final bool hasActiveSub = sub != null && sub['status'] == 'active';

                        return Row(
                          children: [
                            Text(
                              hasActiveSub 
                                  ? (sub['plan']?['name'] ?? "Active Plan") 
                                  : "No Active Plans",
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (!hasActiveSub)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttonColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Get.to(() => const GoPremiumPage()),
                                child: const Text("SUBSCRIBE", style: TextStyle(color: AppColors.white, fontSize: 12)),
                              )
                            else
                              const Icon(Icons.verified, color: Colors.green, size: 24),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            buildMenuItem(context, Icons.person_outline, "My Account", const AccountSettingsPage()),
            buildMenuItem(context, Icons.bookmark_border, "Watchlist", const WatchlistPage()),
            buildMenuItem(context, Icons.settings_outlined, "Settings", const SettingsPage()),
            buildMenuItem(context, Icons.rate_review, "Rate Our App", const ReviewPage()),
            buildMenuItem(context, Icons.info_outline, "Terms & Conditions", const TermsAndConditionsPage()),
            buildMenuItem(context, Icons.privacy_tip, "Privacy Policy", const PrivacyPolicyPage()),
            buildMenuItem(context, Icons.currency_rupee, "Refund Policy", const RefundPolicyPage()),
            buildMenuItem(context, Icons.help_outline, "Help", const HelpSupportPage()),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: onLogout,
                child: const Text("SIGN OUT", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
            const Text("App Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(BuildContext context, IconData icon, String title, Widget page) {
    return InkWell(
      onTap: () => Get.to(() => page),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(color: AppColors.white, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}
