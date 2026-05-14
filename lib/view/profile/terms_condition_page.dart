import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/profile/privacy_controller.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller find या put करें
    final PrivacyController controller = Get.put(PrivacyController());

    // Page लोड होने पर डेटा फेच करें (बिना setState के)
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
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoadingTerms.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.pink),
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
    );
  }
}
