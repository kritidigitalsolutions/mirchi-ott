import 'package:get/get.dart';

class DramaDetailsController extends GetxController {
  var isWatchlist = false.obs;
  var isLiked = false.obs;
  var isDisliked = false.obs;
  
  var selectedSeason = 1.obs;

  void toggleWatchlist() => isWatchlist.value = !isWatchlist.value;

  void toggleLike() {
    isLiked.value = !isLiked.value;
    if (isLiked.value) isDisliked.value = false;
  }

  void toggleDislike() {
    isDisliked.value = !isDisliked.value;
    if (isDisliked.value) isLiked.value = false;
  }
}
