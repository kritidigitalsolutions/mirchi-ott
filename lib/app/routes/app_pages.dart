import 'package:get/get.dart';
import '../../view/auth/otpPage.dart';
import '../../view/auth/signInPage.dart';
import '../../view/homePages/mainHomepage.dart';
import '../../view/splash/splashScreen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const MainHomePage()),
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.signIn, page: () => const SignInPage()),
    GetPage(name: AppRoutes.otpPage, page: () => const OtpPage(phoneNumber: '')),
    // GetPage(name: AppRoutes.dramaDetails, page: () => SplashScreen()),
    // ... other routes
  ];
}
