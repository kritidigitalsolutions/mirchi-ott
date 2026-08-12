import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/routes/app_routes.dart';
import '../../utils/app_images.dart';

class SplashScreen extends StatefulWidget {
  final bool isWrapper;
  const SplashScreen({super.key, this.isWrapper = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    
    // Navigate to home screen after 3 seconds only if not used as a wrapper
    if (!widget.isWrapper) {
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Get.offAllNamed(AppRoutes.navbar);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          AppImages.logo,
          width: 400, // Adjust the size as needed
        ),
      ),
    );
  }
}
