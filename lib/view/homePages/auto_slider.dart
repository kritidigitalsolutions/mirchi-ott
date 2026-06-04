import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/app_images.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../auth/signInPage.dart';
import '../dramaDetails/dramaDetailsPage.dart';
import '../premium/goPremium.dart';
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
    _pageController = PageController(
      viewportFraction: Responsive.isDesktop(Get.context!) ? 0.9 : 0.8,
      initialPage: 1000,
    );
    currentPage = 1000;
    _startTimer();
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

    if (widget.content.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
            height: isDesktop ? 750 : MediaQuery.of(context).size.height * 0.40,
            child: PageView.builder(
              controller: _pageController,
              itemCount: null,
              onPageChanged: (index) => setState(() => currentPage = index),
              itemBuilder: (context, index) {
                final item = widget.content[index % widget.content.length];
                bool isSelected = currentPage == index;
                double scale = isSelected ? 1 : 0.92;

                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: scale, end: scale),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(scale: value, child: child),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GestureDetector(
                      onTap: () {
                        if (!widget.isSignedIn) {
                           Get.to(() => const SignInPage());
                        } else {
                           Get.to(() => DramaDetailsPage(isSignedIn: widget.isSignedIn, content: item));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.black.withOpacity(0.5),
                              blurRadius: 25,
                              spreadRadius: 2,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              /// CINEMATIC IMAGE WITH ZOOM
                              AnimatedScale(
                                duration: const Duration(seconds: 5),
                                scale: isSelected ? 1.1 : 1.0,
                                child: Image.network(
                                  isDesktop ? item.banner : item.poster,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    AppImages.farzi,
                                    fit: BoxFit.cover,
                                  ),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                                  },
                                ),
                              ),
                              /// TOP GRADIENT (Darker for Navbar contrast)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.center,
                                    stops: const [0.0, 0.4],
                                    colors: [
                                      Colors.black.withOpacity(0.9),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              /// BOTTOM GRADIENT (Cinematic fade)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.center,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.9),
                                    ],
                                  ),
                                ),
                              ),
                              /// CONTENT
                              Positioned(
                                bottom: isDesktop ? 80 : 40,
                                left: 50,
                                right: 50,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 600),
                                  opacity: isSelected ? 1 : 0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.title.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: isDesktop ? 56 : 26,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.red.withOpacity(0.8),
                                              offset: const Offset(0, 0),
                                              blurRadius: 20,
                                            ),
                                            Shadow(
                                              color: Colors.black,
                                              offset: const Offset(3, 5),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
