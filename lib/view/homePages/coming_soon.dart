import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/theme/app_colors.dart';
import 'package:mirchi_ott/data/models/response_model/content_response_model/content_model.dart';
import '../dramaDetails/dramaDetailsPage.dart';

class ComingSoonSection extends StatelessWidget {
  final List<ContentModel> content;
  final bool isSignedIn;

  const ComingSoonSection({
    super.key,
    required this.content,
    required this.isSignedIn,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 CLICKABLE TITLE (Coming Soon >)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () {
              // Get.to(() => MoreComingSoonPage());
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Coming Soon",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        /// 🔥 SLIDER
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: content.length,
            itemBuilder: (context, index) {
              final item = content[index];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Get.to(() => DramaDetailsPage(isSignedIn: isSignedIn, content: item));
                  },
                  child: Stack(
                    children: [
                      /// Poster Image
                      // lib/modules/homePages/coming_soon.dart

                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          item.poster ?? "",
                          height: 250,
                          width: 170,
                          fit: BoxFit.cover,
                          // Agar URL galat ho ya image load na ho
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 250,
                            width: 170,
                            color: Colors.grey[900],
                            child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
                          ),
                          // Agar URL null ho (Loading state)
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 250,
                              width: 170,
                              color: Colors.grey[900],
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        ),
                      ),

                      /// 🔥 FULL WIDTH DATE LABEL
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _formatDate(item.releaseDate),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Coming Soon";
    try {
      final date = DateTime.parse(dateStr);
      // Simple formatting: 31 March
      final months = ["Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
      return "${date.day} ${months[date.month - 1]}";
    } catch (e) {
      return "Coming Soon";
    }
  }
}
