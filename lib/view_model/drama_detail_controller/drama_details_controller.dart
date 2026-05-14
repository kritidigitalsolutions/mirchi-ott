import 'package:get/get.dart';

class DramaDetailsController extends GetxController {
  var isWatchlist = false.obs;
  var isLiked = false.obs;
  var isDisliked = false.obs;

  void toggleWatchlist() => isWatchlist.value = !isWatchlist.value;

  void toggleLike() {
    isLiked.value = !isLiked.value;
    if (isLiked.value) isDisliked.value = false;
  }

  void toggleDislike() {
    isDisliked.value = !isDisliked.value;
    if (isDisliked.value) isLiked.value = false;
  }

  final List<Map<String, String>> cast = [
    {'name': 'Shahid Kapoor', 'image': 'assets/images/Shahid_Kapoor.jpg'},
    {'name': 'Saru khan', 'image': 'assets/images/srk.jpeg'},
    {'name': 'Alia bhatta', 'image': 'assets/images/alia.jpeg'},
    {'name': 'Katarina', 'image': 'assets/images/katarina.jpeg'},
    {'name': 'Salman', 'image': 'assets/images/salman.jpeg'},
    {'name': 'Ranvir', 'image': 'assets/images/ranvir.jpg'},
  ];
}
