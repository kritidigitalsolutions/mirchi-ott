// import 'package:get/get.dart';
//
// class ReviewController extends GetxController {
//   var rating = 0.obs;
//   var comment = "".obs;
//
//   void updateRating(int value) => rating.value = value;
//   void updateComment(String value) => comment.value = value;
//
//   void submitReview() {
//     if (rating.value == 0) {
//       Get.snackbar("Error", "Please select a rating");
//       return;
//     }
//     // API logic for submitting review can go here
//     Get.snackbar("Success", "Thank you for your review!");
//     Get.back();
//   }
// }
