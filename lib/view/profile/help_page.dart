import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/profile/privacy_controller.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final PrivacyController controller = Get.put(PrivacyController());

  @override
  void initState() {
    super.initState();
    controller.fetchHelpData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Help & Support",
          style: TextStyle(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Obx(() {
        if (controller.isLoadingHelp.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.helpData.isEmpty) {
          return const Center(
            child: Text(
              "No Help Data Found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.helpData.length,
          itemBuilder: (context, index) {
            final help = controller.helpData[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                title: Text(
                  help['question'] ?? "",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                iconColor: AppColors.buttonColor,
                collapsedIconColor: Colors.white,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      help['answer'] ?? "",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
