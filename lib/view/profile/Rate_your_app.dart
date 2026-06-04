import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/profile/review_controller.dart';
import '../../view_model/review_controller/review_controller.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReviewController controller = Get.put(ReviewController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Rate Our App",
          style: TextStyle(color: Colors.white),
        ),
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  /// ⭐ Title
                  const Text(
                    "Enjoying Mirchi OTT?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ✍️ Subtitle
                  const Text(
                    "Your feedback helps us improve!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// ⭐ Rating Stars
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            splashRadius: 25,
                            icon: Icon(
                              index < controller.rating.value
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 40,
                            ),
                            onPressed: () => controller.updateRating(index + 1),
                          );
                        }),
                      )),

                  const SizedBox(height: 30),

                  /// 📝 Review Input
                  TextField(
                    onChanged: controller.updateComment,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// 🚀 Submit Button with Loader
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.submitReview,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Submit Review",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      )),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
