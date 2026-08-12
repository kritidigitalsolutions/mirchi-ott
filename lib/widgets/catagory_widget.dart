import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_routes.dart';
import '../data/models/response_model/content_response_model/content_model.dart';
import '../utils/responsive.dart';
import '../view/dramaDetails/dramaDetailsPage.dart';
import 'custom_network_image.dart';

class CategoryGridPage extends StatelessWidget {
  final String title;
  final List<ContentModel> content;
  final bool isSignedIn;

  const CategoryGridPage({
    super.key,
    required this.title,
    required this.content,
    required this.isSignedIn,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isDesktop ? AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ) : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                /// 🔙 BACK + TITLE (Mobile only)
                if (!isDesktop) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  child: Row(
                    children: [
                      Responsive.backButton(context, onPressed: () => Get.back()),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔥 GRID IMAGES
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    itemCount: content.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 6 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final item = content[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Get.toNamed(AppRoutes.dramaDetails, arguments: item);
                        },
                        child: CustomNetworkImage(
                          imageUrl: item.poster,
                          fit: BoxFit.cover,
                          borderRadius: 12,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
