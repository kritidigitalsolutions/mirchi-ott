import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_images.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/catagory_widget.dart';
import '../auth/signInPage.dart';
import '../dramaDetails/dramaDetailsPage.dart';

class Top10List extends StatelessWidget {
  final List<ContentModel> content;
  final bool isSignedIn;

  const Top10List({super.key, required this.content, required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 TOP 10 TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () {
              // Get.to(() => CategoryGridPage(
              //   title: "Top 10",
              //   content: content,
              //   isSignedIn: isSignedIn, items: [],
              // ));
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Top 10",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// 🔥 SLIDER
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: content.length > 10 ? 10 : content.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final item = content[index];
              return GestureDetector(
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
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        bottom: -10,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 150,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1
                              ..color = Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),

                      /// Poster Image
                      Positioned(
                        left: 35,
                        top: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.poster,
                            width: 95,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              AppImages.farzi,
                              width: 95,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
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
