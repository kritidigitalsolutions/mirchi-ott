import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/profile/privacy_controller.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PrivacyController controller = Get.put(PrivacyController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.termsContent.isEmpty) {
        controller.fetchTerms();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Obx(() {
            if (controller.isLoadingTerms.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.termsTitle.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    controller.termsContent.value,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "© 2026 Mirchi OTT",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
