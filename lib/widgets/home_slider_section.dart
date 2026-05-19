import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_images.dart';
import '../data/models/response_model/content_response_model/content_model.dart';
import '../view/auth/signInPage.dart';
import '../view/dramaDetails/dramaDetailsPage.dart';
import 'catagory_widget.dart';

class HomeSliderSection extends StatelessWidget {
  final String title;
  final List<ContentModel> content;
  final bool isSignedIn;

  const HomeSliderSection({
    super.key,
    required this.title,
    required this.content,
    required this.isSignedIn,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 CLICKABLE TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () {
              Get.to(() => CategoryGridPage(
                    title: title,
                    content: content,
                    isSignedIn: isSignedIn,
                  ));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.white),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        /// 🔥 SLIDER IMAGES
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: content.length,
            itemBuilder: (context, index) {
              final item = content[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (!isSignedIn) {
                      Get.to(() => const SignInPage());
                    } else {
                      Get.to(() => DramaDetailsPage(
                            isSignedIn: isSignedIn,
                            content: item,
                          ));
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        AppImages.farzi,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
