import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/app_images.dart';
import '../../view_model/content_controller/content_controller.dart';
import '../navbar/bottomNavbar.dart';
import '../dramaDetails/dramaDetailsPage.dart';
import 'auto_slider.dart';
import 'coming_soon.dart';
import '../navbar/downloads.dart';
import '../../widgets/home_slider_section.dart';
import '../search_pages/searchPage.dart';
import 'top_10_list.dart';
import '../auth/signInPage.dart';
import '../premium/goPremium.dart';
import '../profile/profilePage.dart';
import '../../view_model/home_controller/home_controller.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../utils/notification_service.dart';
import '../notifications/notification_page.dart';

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ContentController contentController = Get.put(ContentController());
    final HomeController controller = Get.put(HomeController());
    final AuthController authController = Get.find<AuthController>();
    final notificationService = NotificationService.to;

    return PopScope(
      canPop: false, // ❌ direct pop disable
      onPopInvoked: (didPop) {
        final controller = Get.find<HomeController>();

        if (controller.selectedIndex.value != 0) {
          controller.selectedIndex.value = 0; // ✅ Home pe le jao
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
                    _buildHomeContent(
                      context,
                      controller,
                      authController,
                      contentController,
                      notificationService,
                    ),
                    const SearchPage(),
                    const GoPremiumPage(),
                    const DownloadsPage(),

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

              if (selectedIndex != 2) {
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomBottomNavbar(
                    selectedIndex: selectedIndex,
                    onItemTapped: (index) {
                      /// 🔥 LOGIN GUARD
                      if (index == 4 && !isLoggedIn) {
                        Get.to(() => const SignInPage());
                        return;
                      }

                      controller.onItemTapped(index);
                    },
                    isLoggedIn: isLoggedIn,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(AppImages.logo,
                  height: 80),
              Row(
                children: [
                  Obx(() {
                    int unreadCount = notificationService.notifications
                        .where((n) => n['isRead'] == false)
                        .length;
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.to(() => const NotificationPage());
                          },
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
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const GoPremiumPage());
                      },
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
        ),

        /// SCROLL
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),

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
                                Get.to(
                                  () => DramaDetailsPage(
                                    isSignedIn: authController.isLoggedIn.value,
                                    content: item,
                                  ),
                                );
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

                const SizedBox(height: 10),

                Obx(
                  () => ComingSoonSection(
                    content: contentController.allContent
                        .where((c) => c.isComingSoon == true)
                        .toList(),
                    isSignedIn: authController.isLoggedIn.value,
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
