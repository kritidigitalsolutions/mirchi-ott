import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/app_images.dart';
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

// ... (existing imports)

class _AutoSliderState extends State<AutoSlider> {
  late PageController _pageController;
  int currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: 1000,
    );
    currentPage = 1000;
    _startTimer();
  }

  void _startTimer() {
    if (_timer?.isActive ?? false) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        currentPage++;
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
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
    final PremiumController premiumController = Get.put(PremiumController());

    if (widget.content.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          child: PageView.builder(
            controller: _pageController,
            itemCount: null,
            onPageChanged: (index) => setState(() => currentPage = index),
            itemBuilder: (context, index) {
              final item = widget.content[index % widget.content.length];
              double scale = currentPage == index ? 1 : 0.9;

              return TweenAnimationBuilder(
                tween: Tween<double>(begin: scale, end: scale),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      if (!widget.isSignedIn) {
                         Get.to(() => const SignInPage());
                      } else {
                         Get.to(() => DramaDetailsPage(isSignedIn: widget.isSignedIn, content: item));
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            item.banner,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              AppImages.farzi,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(color: AppColors.black.withOpacity(0.3)),
                          Positioned(
                            bottom: 25,
                            left: 0,
                            right: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
        const SizedBox(height: 18),
        // ... Pagination dots Row ...
      ],
    );
  }
}