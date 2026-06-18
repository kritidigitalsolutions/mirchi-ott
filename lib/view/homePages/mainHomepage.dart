import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/responsive.dart';
import '../../view_model/content_controller/content_controller.dart';
import '../../widgets/custom_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
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
      canPop: kIsWeb, 
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (controller.selectedIndex.value != 1) {
          controller.selectedIndex.value = 1; 
        } else {
          Navigator.of(context).pop(); 
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Responsive(
          mobile: _buildMobileLayout(context, controller, authController, contentController, notificationService),
          desktop: _buildDesktopLayout(context, controller, authController, contentController, notificationService),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    HomeController controller,
    AuthController authController,
    ContentController contentController,
    NotificationService notificationService,
  ) {
    return Stack(
      children: [
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
                  controller.onItemTapped(index);
                },
                isLoggedIn: isLoggedIn,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    HomeController controller,
    AuthController authController,
    ContentController contentController,
    NotificationService notificationService,
  ) {
    return Column(
      children: [
        /// HEADER AT TOP
        _buildDesktopHeader(notificationService, controller, authController),
        
        /// CONTENT BELOW HEADER
        Expanded(
          child: Obx(
            () => IndexedStack(
              index: controller.selectedIndex.value,
              children: [
                _buildUpcomingContent(notificationService, authController, isDesktop: true),
                _buildHomeContent(
                  context,
                  controller,
                  authController,
                  contentController,
                  notificationService,
                  isDesktop: true,
                ),
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
      ],
    );
  }

  Widget _buildDesktopHeader(NotificationService notificationService, HomeController controller, AuthController authController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black, // Solid background
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => controller.onItemTapped(1),
            child: Image.asset(AppImages.logo1, height: 50),
          ),
          const SizedBox(width: 40),
          _navItem("Upcoming", 0, controller),
          const SizedBox(width: 20),
          _navItem("Profile", 2, controller),
          const Spacer(),
          IconButton(
            onPressed: () => Get.to(() => const SearchPage()),
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
          ),
          _buildNotificationIcon(notificationService),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () => Get.to(() => const GoPremiumPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Go Premium", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, int index, HomeController controller) {
    return Obx(() {
      bool isSelected = controller.selectedIndex.value == index;
      return TextButton(
        onPressed: () => controller.onItemTapped(index),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    });
  }

  Widget _buildNotificationIcon(NotificationService notificationService) {
    return Obx(() {
      int unreadCount = notificationService.notifications
          .where((n) => n['isRead'] == false)
          .length;
      return Stack(
        children: [
          IconButton(
            onPressed: () => Get.to(() => const NotificationPage()),
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }

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
              _buildNotificationIcon(notificationService),
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

  Widget _buildUpcomingContent(NotificationService notificationService, AuthController authController, {bool isDesktop = false}) {
    return Column(
      children: [
        if (!isDesktop) _buildHeader(notificationService),
        Expanded(child: ComingSoonSection(content: [], isSignedIn: authController.isLoggedIn.value, isFullPage: true)),
      ],
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    HomeController controller,
    AuthController authController,
    ContentController contentController,
    NotificationService notificationService, {
    bool isDesktop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop) _buildHeader(notificationService),
        Expanded(
          child: Obx(() {
            if (contentController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  AutoSlider(
                    content: contentController.allContent
                        .where((c) => c.category.contains('trending') && c.isComingSoon == false)
                        .toList(),
                    isSignedIn: authController.isLoggedIn.value,
                  ),
                  
                  SizedBox(height: isDesktop ? 30 : 0),

                  _buildAnimatedSection(
                    isDesktop: isDesktop,
                    delay: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Web Series",
                            style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
                        ),
                        // const SizedBox(height: 20),
                        Obx(() {
                          final seriesContent = contentController.allContent
                              .where((c) => c.contentType == 'series' && c.isComingSoon == false)
                              .toList();

                          return SizedBox(
                            height: isDesktop ? 340 : 170,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              itemCount: seriesContent.length,
                              itemBuilder: (context, index) {
                                final item = seriesContent[index];
                                return _WebSeriesHoverCard(item: item, isSignedIn: authController.isLoggedIn.value, isDesktop: isDesktop);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildAnimatedSection(
                    isDesktop: isDesktop,
                    delay: 400,
                    child: Top10List(
                      content: contentController.allContent.where((c) => c.category.contains('top10') && c.isComingSoon == false).toList(),
                      isSignedIn: authController.isLoggedIn.value,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildAnimatedSection(
                    isDesktop: isDesktop,
                    delay: 600,
                    child: HomeSliderSection(
                      title: "Mirchi Exclusives",
                      content: contentController.allContent.where((c) => c.contentType == 'movie' && c.isComingSoon == false).toList(),
                      isSignedIn: authController.isLoggedIn.value,
                    ),
                  ),
                  
                  _buildFooter(),
                  const SizedBox(height: 100),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection({required bool isDesktop, required int delay, required Widget child}) {
    if (!isDesktop) return child;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 1000 + delay),
      curve: Curves.easeOutQuart,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      color: Colors.black,
      child: Column(
        children: [
          Image.asset(AppImages.logo1, height: 80),
          const SizedBox(height: 20),
          const Text("MIRCHI OTT", style: TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 30),
          const Text("The ultimate destination for premium regional content. Watch the latest web series, movies, and originals anytime, anywhere.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
          const SizedBox(height: 20),
          InkWell(
            onTap: () => launchUrl(Uri.parse("mailto:support@mirchiapp.in")),
            child: const Text("Email: support@mirchiapp.in", style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 30,
            runSpacing: 20,
            children: [
              _footerLink("Privacy Policy", AppRoutes.privacy),
              _footerLink("Terms & Conditions", AppRoutes.terms),
              _footerLink("Refund Policy", AppRoutes.refund),
              _footerLink("Help & Support", AppRoutes.help),
            ],
          ),
          const SizedBox(height: 50),
          const Divider(color: Colors.white12),
          const SizedBox(height: 30),
          const Text("© 2024 Mirchi OTT All Rights Reserved", style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("POWERED BY", style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5)),
              const SizedBox(width: 8),
              const Text("WHITE MULTIMEDIA", style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            ],
          ),
          const SizedBox(height: 20),
          const Column(
            children: [
              Text("Floor No 12, 1202, Residences Tanaji Nagar,", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text("Tanaji Nagar Road No 1, Near Time of India off, W.E. Highway,", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text("Malad East, Mumbai, Maharashtra - 400097", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String title, String route) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _WebSeriesHoverCard extends StatefulWidget {
  final dynamic item;
  final bool isSignedIn;
  final bool isDesktop;

  const _WebSeriesHoverCard({required this.item, required this.isSignedIn, required this.isDesktop});

  @override
  State<_WebSeriesHoverCard> createState() => _WebSeriesHoverCardState();
}

class _WebSeriesHoverCardState extends State<_WebSeriesHoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.isDesktop ? (isHovered ? 230 : 200) : 130,
        margin: const EdgeInsets.only(right: 32),
        transform: isHovered 
          ? (Matrix4.identity()..translate(0, -15, 0)..scale(1.05)) 
          : Matrix4.identity(),
        child: GestureDetector(
          onTap: () {
            Get.to(() => DramaDetailsPage(isSignedIn: widget.isSignedIn, content: widget.item));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: isHovered ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 3,
                  offset: const Offset(0, 10),
                )
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: CustomNetworkImage(
              imageUrl: widget.item.poster,
              fit: BoxFit.fill,
              borderRadius: 15,
            ),
          ),
        ),
      ),
    );
  }
}
