import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import 'package:mirchi_ott/utils/constants.dart';
import 'package:mirchi_ott/view_model/home_controller/home_controller.dart';
import 'package:mirchi_ott/widgets/custom_network_image.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/auth_controller/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final PremiumController premiumController =
        Get.isRegistered<PremiumController>()
        ? Get.find<PremiumController>()
        : Get.put(PremiumController());
    final HomeController homeController = Get.find<HomeController>();
    bool isDesktop = Responsive.isDesktop(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isLoggedIn.value) {
        authController.getProfile();
      }
      if (authController.isLoggedIn.value &&
          premiumController.subscriptionData.value == null) {
        premiumController.fetchSubscriptionStatus();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      homeController.selectedIndex.value = 1;
                    },
                  ),
                ),
              ),
              title: const Text(
                "Profile",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _handleEditProfile(authController),
                  ),
                ),
              ],
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                /// TOP AMBIENT PROFILE HEADER
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.3,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Obx(() {
                    final bool isLoggedIn = authController.isLoggedIn.value;
                    final user = authController.userData.value;

                    String? imageUrl;
                    if (isLoggedIn && user != null) {
                      imageUrl =
                          user['avatar'] ??
                          user['image'] ??
                          user['profileImage'];
                      if (imageUrl != null &&
                          imageUrl.isNotEmpty &&
                          !imageUrl.startsWith('http')) {
                        imageUrl = "${AppConstants.serverUrl}/$imageUrl";
                      }
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 8),

                        /// CIRCULAR AVATAR WITH WARM RING & EDIT BADGE
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: const Color(0xFF222222),
                                child: (imageUrl != null && imageUrl.isNotEmpty)
                                    ? CustomNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        width: 92,
                                        height: 92,
                                        borderRadius: 46,
                                        placeholder: const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.buttonColor,
                                                ),
                                          ),
                                        ),
                                        errorWidget: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 45,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 45,
                                      ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _handleEditProfile(authController),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// USER NAME
                        Text(
                          isLoggedIn
                              ? _getUserDisplayName(user)
                              : "Welcome Guest",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// USER EMAIL / PHONE
                        Text(
                          isLoggedIn
                              ? ((user?['email'] != null &&
                                        user!['email'].toString().isNotEmpty)
                                    ? user['email']
                                    : (user?['phone'] ?? "No Contact Info"))
                              : "Sign in to access all features",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                ),

                const SizedBox(height: 18),

                /// GROUP 1: ACCOUNT & CONTENT
                _buildCardGroup(
                  children: [
                    Obx(() {
                      final bool isLoggedIn = authController.isLoggedIn.value;
                      final sub = premiumController.subscriptionData.value;
                      final bool hasActiveSub =
                          isLoggedIn && sub != null && sub['status'] == 'active';
                      final String planName =
                          sub?['plan']?['name'] ?? "Premium Plan";
                      final String expiryDate = premiumController.formatDate(
                        sub?['endDate'] ?? sub?['expiryDate'],
                      );

                      return _buildSubscriptionTile(
                        context: context,
                        hasActiveSub: hasActiveSub,
                        isLoggedIn: isLoggedIn,
                        subtitle: isLoggedIn
                            ? (hasActiveSub
                                ? "$planName • Expires on $expiryDate"
                                : "No active plan • Tap to subscribe")
                            : "Login to view or manage subscription",
                        onTap: () {
                          if (!isLoggedIn) {
                            Get.toNamed(AppRoutes.signIn);
                          } else if (hasActiveSub) {
                            Get.toNamed(AppRoutes.purchasedPlans);
                          } else {
                            premiumController.navigateToPremiumOrManageAccount(
                              context,
                            );
                          }
                        },
                      );
                    }),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.bookmark_border,
                      title: "Watchlist",
                      onTap: () => Get.toNamed(AppRoutes.watchList),
                    ),
                    if (!kIsWeb) ...[
                      _buildDivider(),
                      _buildTile(
                        icon: Icons.download_for_offline_outlined,
                        title: "Downloads",
                        onTap: () => Get.toNamed(AppRoutes.downloads),
                      ),
                    ],
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      onTap: () => Get.toNamed(AppRoutes.setting),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// GROUP 2: RATING & SUPPORT
                _buildCardGroup(
                  children: [
                    _buildTile(
                      icon: Icons.star_border_rounded,
                      title: "Rate Our App",
                      onTap: () => Get.toNamed(AppRoutes.rateApp),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.help_outline_rounded,
                      title: "Help & Support",
                      onTap: () => Get.toNamed(AppRoutes.help),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// GROUP 3: POLICIES & TERMS
                _buildCardGroup(
                  children: [
                    _buildTile(
                      icon: Icons.description_outlined,
                      title: "Terms & Conditions",
                      onTap: () => Get.toNamed(AppRoutes.terms),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.shield_outlined,
                      title: "Privacy Policy",
                      onTap: () => Get.toNamed(AppRoutes.privacy),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.currency_rupee,
                      title: "Refund Policy",
                      onTap: () => Get.toNamed(AppRoutes.refund),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// SIGN OUT / SIGN IN BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    final bool isLoggedIn = authController.isLoggedIn.value;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: isLoggedIn
                          ? onLogout
                          : () => Get.toNamed(AppRoutes.signIn),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLoggedIn ? Icons.logout : Icons.login,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isLoggedIn ? "SIGN OUT" : "SIGN IN",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),
                const Text(
                  "App Version 1.0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 30),
                if (!isDesktop) const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleEditProfile(AuthController authController) {
    if (authController.isLoggedIn.value) {
      final user = authController.userData.value;
      final currentPhone = user?['phone']?.toString() ?? "";
      Get.toNamed(AppRoutes.createProfile, arguments: currentPhone);
    } else {
      Get.toNamed(AppRoutes.signIn);
    }
  }

  Widget _buildCardGroup({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white24,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionTile({
    required BuildContext context,
    required bool hasActiveSub,
    required bool isLoggedIn,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: hasActiveSub ? AppColors.primary : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Subscription",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasActiveSub)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  child: const Text(
                    "ACTIVE",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isLoggedIn ? "SUBSCRIBE" : "SIGN IN",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white24,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.05),
      height: 1,
      indent: 56,
      endIndent: 16,
    );
  }

  String _getUserDisplayName(Map<String, dynamic>? user) {
    if (user == null) return "User Name";
    String? name = user['name'] ?? user['fullName'];
    if (name != null &&
        name.toString().trim().isNotEmpty &&
        !_isGenericName(name.toString())) {
      return name.toString().trim();
    }
    String email = user['email']?.toString() ?? "";
    if (email.contains('@')) {
      String local = email.split('@')[0];
      local = local.replaceAll(RegExp(r'\d+$'), '');
      local = local.replaceAll(RegExp(r'[\._\-\d]+'), ' ').trim();
      if (local.isNotEmpty) {
        return local
            .split(' ')
            .where((s) => s.isNotEmpty)
            .map((w) {
              return w[0].toUpperCase() + w.substring(1).toLowerCase();
            })
            .join(' ');
      }
    }
    return "User Name";
  }

  bool _isGenericName(String name) {
    String s = name.trim().toLowerCase();
    return s.isEmpty ||
        s == "user" ||
        s == "user name" ||
        s == "null" ||
        s == "n/a" ||
        s == "guest";
  }
}
