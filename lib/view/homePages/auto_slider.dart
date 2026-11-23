import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import 'package:mirchi_ott/widgets/custom_network_image.dart';
import '../../app/routes/app_routes.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../app/theme/app_colors.dart';

class AutoSlider extends StatefulWidget {
  final List<ContentModel> content;
  final bool isSignedIn;

  const AutoSlider({
    super.key,
    required this.content,
    required this.isSignedIn,
  });

  @override
  State<AutoSlider> createState() => _AutoSliderState();
}

class _AutoSliderState extends State<AutoSlider> {
  late PageController _pageController;
  int currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    int startingPage = widget.content.isNotEmpty
        ? 1000 - (1000 % widget.content.length)
        : 0;

    _pageController = PageController(
      viewportFraction: Responsive.isDesktop(Get.context!) ? 0.88 : 1.0,
      initialPage: startingPage,
    );
    currentPage = startingPage;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant AutoSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure viewportFraction is strictly 1.0 on mobile after any reload
    final expectedFraction = Responsive.isDesktop(context) ? 0.88 : 1.0;
    if (_pageController.viewportFraction != expectedFraction) {
      _stopTimer();
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: expectedFraction,
        initialPage: currentPage,
      );
      _startTimer();
    }
  }

  void _startTimer() {
    if (_timer?.isActive ?? false) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        currentPage++;
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Responsive.isDesktop(context);
    double screenWidth = MediaQuery.of(context).size.width;

    if (widget.content.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // 16:9 widescreen landscape banner height on mobile
    double mobileBannerHeight = (screenWidth - 32) * (9 / 16);
    double bannerHeight = isDesktop
        ? MediaQuery.of(context).size.height * 0.8
        : mobileBannerHeight.clamp(190.0, 230.0);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutExpo,
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(
            height: bannerHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: null,
              onPageChanged: (index) => setState(() => currentPage = index),
              itemBuilder: (context, index) {
                final item = widget.content[index % widget.content.length];
                final String bannerUrl =
                    item.banner.isNotEmpty ? item.banner : item.poster;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.dramaDetails, arguments: item);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(isDesktop ? 0 : 16),
                        boxShadow: isDesktop
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isDesktop ? 0 : 16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            /// CINEMATIC LANDSCAPE BANNER
                            CustomNetworkImage(
                              imageUrl: bannerUrl,
                              fit: BoxFit.cover,
                              borderRadius: isDesktop ? 0 : 16,
                            ),

                            /// TOP GRADIENT
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.center,
                                  stops: const [0.0, 0.4],
                                  colors: [
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            /// BOTTOM GRADIENT
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.45),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔴 3-DOT PAGINATION INDICATOR (Left Dot, Center Red Pill, Right Dot)
          if (!isDesktop && widget.content.length > 1) ...[
            const SizedBox(height: 12),
            _buildDots(),
          ],

          SizedBox(height: isDesktop ? 25 : 10),
        ],
      ),
    );
  }

  Widget _buildDots() {
    int total = widget.content.length;
    int dotCount = total < 3 ? total : 3;
    int current = currentPage % total;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (i) {
        bool isActive = total <= 3 ? (current == i) : (i == 1);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 22 : 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
