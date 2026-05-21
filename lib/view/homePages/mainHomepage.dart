import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/app_images.dart';
import '../../view_model/content_controller/content_controller.dart';
import '../navbar/bottomNavbar.dart';
import '../dramaDetails/dramaDetailsPage.dart';
import 'auto_slider.dart';
import 'coming_soon.dart';
import '../../widgets/home_slider_section.dart';
import '../search_pages/searchPage.dart';
import 'top_10_list.dart';
import '../auth/signInPage.dart';
import '../premium/goPremium.dart';
import '../profile/profilePage.dart';
import '../shorts/shorts_page.dart';
import '../../view_model/home_controller/home_controller.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../utils/notification_service.dart';
import '../notifications/notification_page.dart';

import '../profile/privacy_policy_page.dart';
import '../profile/terms_condition_page.dart';
import '../profile/refund_policy_page.dart';
import '../profile/help_page.dart';

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ContentController contentController = Get.put(ContentController());
    final HomeController controller = Get.put(HomeController());
    final AuthController authController = Get.find<AuthController>();
    final notificationService = NotificationService.to;

    return PopScope(
      canPop: false, 
      onPopInvoked: (didPop) {
        if (controller.selectedIndex.value != 1) {
          controller.selectedIndex.value = 1; // ✅ Home pe le jao
        } else {
          Navigator.of(context).pop(); // ✅ App exit
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            /// ✅ PAGE CONTENT
            SafeArea(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: [
                    _buildUpcomingContent(notificationService, authController),
                    _buildHomeContent(
                      context,
                      controller,
                      authController,
                      contentController,
                      notificationService,
                    ),
                    /// ✅ ONLY PROFILE HERE
                    ProfilePage(
                      onLogout: () {
                        controller.logout();
                        authController.setLoginStatus(false);
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// ✅ BOTTOM NAVBAR
            Obx(() {
              int selectedIndex = controller.selectedIndex.value;
              bool isLoggedIn = authController.isLoggedIn.value;

              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: CustomBottomNavbar(
                    selectedIndex: selectedIndex,
                    onItemTapped: (index) {
                      /// 🔥 Removed mandatory redirect to SignIn for all tabs
                      controller.onItemTapped(index);
                    },
                    isLoggedIn: isLoggedIn,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 🔹 HEADER
  Widget _buildHeader(NotificationService notificationService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(AppImages.logo1, height: 50),
          Row(
            children: [
              IconButton(
                onPressed: () => Get.to(() => const SearchPage()),
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
              ),
              Obx(() {
                int unreadCount = notificationService.notifications
                    .where((n) => n['isRead'] == false)
                    .length;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => Get.to(() => const NotificationPage()),
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 28),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(width: 4),
              SizedBox(
                width: 100,
                height: 28,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const GoPremiumPage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    "Go Premium",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 UPCOMING CONTENT
  Widget _buildUpcomingContent(NotificationService notificationService, AuthController authController) {
    return Column(
      children: [
        _buildHeader(notificationService),
        Expanded(child: ComingSoonSection(content: [], isSignedIn: authController.isLoggedIn.value, isFullPage: true)),
      ],
    );
  }

  /// 🔹 HOME CONTENT
  Widget _buildHomeContent(
    BuildContext context,
    HomeController controller,
    AuthController authController,
    ContentController contentController,
    NotificationService notificationService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        _buildHeader(notificationService),

        /// SCROLL
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 15),

                Obx(
                  () => AutoSlider(
                    content: contentController.allContent
                        .where(
                          (c) =>
                              c.category.contains('trending') &&
                              c.isComingSoon == false,
                        )
                        .toList(),
                    isSignedIn: authController.isLoggedIn.value,
                  ),
                ),

                const SizedBox(height: 25),

                /// WEB SERIES
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Web Series",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Obx(
                  () {
                    final seriesContent = contentController.allContent
                        .where(
                          (c) =>
                              c.contentType == 'series' &&
                              c.isComingSoon == false,
                        )
                        .toList();

                    return SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: seriesContent.length,
                        itemBuilder: (context, index) {
                          final item = seriesContent[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: GestureDetector(
                              onTap: () {
                                if (!authController.isLoggedIn.value) {
                                  Get.to(() => const SignInPage());
                                } else {
                                  Get.to(
                                    () => DramaDetailsPage(
                                      isSignedIn: authController.isLoggedIn.value,
                                      content: item,
                                    ),
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  item.poster,
                                  width: 130,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    AppImages.farzi,
                                    width: 130,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                Obx(
                  () => Top10List(
                    content: contentController.allContent
                        .where(
                          (c) =>
                              c.category.contains('top10') &&
                              c.isComingSoon == false,
                        )
                        .toList(),
                    isSignedIn: authController.isLoggedIn.value,
                  ),
                ),

                const SizedBox(height: 10),

                Obx(
                  () => HomeSliderSection(
                    title: "Movies",
                    content: contentController.allContent
                        .where(
                          (c) =>
                              c.contentType == 'movie' &&
                              c.isComingSoon == false,
                        )
                        .toList(),
                    isSignedIn: authController.isLoggedIn.value,
                  ),
                ),

                // const SizedBox(height: 10),

                // Obx(
                //   () => ComingSoonSection(
                //     content: contentController.allContent
                //         .where((c) => c.isComingSoon == true)
                //         .toList(),
                //     isSignedIn: authController.isLoggedIn.value,
                //   ),
                // ),
                // const SizedBox(height: 30),
                //
                // _buildFooter(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 🔹 FOOTER
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      // decoration: BoxDecoration(
      //   color: Colors.grey[900]?.withOpacity(0.5),
      //   border: const Border(top: BorderSide(color: Colors.white12)),
      // ),
      child: Column(
        children: [
          Image.asset(AppImages.logo1, height: 60),
          const SizedBox(height: 10),
          const Text(
            "MIRCHI OTT",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "The ultimate destination for premium regional content. Watch the latest web series, movies, and originals anytime, anywhere.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 15,
            children: [
              _footerLink("Privacy Policy", const PrivacyPolicyPage()),
              _footerLink("Terms & Conditions", const TermsAndConditionsPage()),
              _footerLink("Refund Policy", const RefundPolicyPage()),
              _footerLink("Help & Support", const HelpSupportPage()),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          const Text(
            "© 2024 Mirchi OTT. All Rights Reserved.",
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String title, Widget page) {
    return InkWell(
      onTap: () => Get.to(() => page),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
