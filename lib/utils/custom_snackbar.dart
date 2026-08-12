import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/app_colors.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError 
          ? Colors.red.withOpacity(0.8) 
          : isSuccess 
              ? Colors.green.withOpacity(0.8) 
              : AppColors.buttonColor.withOpacity(0.8),
      colorText: Colors.white,
      borderRadius: 15,
      margin: const EdgeInsets.all(15),
      duration: duration,
      icon: Icon(
        isError 
            ? Icons.error_outline 
            : isSuccess 
                ? Icons.check_circle_outline 
                : Icons.info_outline,
        color: Colors.white,
      ),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
    );
  }
}
