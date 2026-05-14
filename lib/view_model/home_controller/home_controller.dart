import 'package:get/get.dart';
import '../../utils/app_session.dart';
import '../auth_controller/auth_controller.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  var isLoggedIn = false.obs;

  final List<String> webSeriesImages = [
    "assets/images/taskaree.jpg",
    "assets/images/sahid_teri_bato.jpg",
    "assets/images/farzi.jpg",
    "assets/images/khaki.webp",
    "assets/images/kota_factory.jpg",
    "assets/images/asur.webp",
    "assets/images/asur2.jpeg",
  ];

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    isLoggedIn.value = AppSession.getLogin();
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  void logout() async {
    final authController = Get.find<AuthController>();
    await authController.logout();
    isLoggedIn.value = false;
    selectedIndex.value = 0;
  }
}
