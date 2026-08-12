import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:mirchi_ott/app/routes/app_pages.dart';
import 'package:mirchi_ott/view_model/content_controller/content_controller.dart';
import 'package:mirchi_ott/view_model/like_dislike_controller/like_dislike_controller.dart';
import 'package:mirchi_ott/view_model/watchlist_controller/watchlist_controller.dart';

import 'app/routes/app_routes.dart';
import 'data/network/api_network_service.dart';
import 'data/network/base_api_service.dart';
import 'utils/ad_service.dart';
import 'utils/app_session.dart';
import 'utils/facebook_events_service.dart';
import 'utils/firebase_analytics_service.dart';
import 'utils/notification_service.dart';
import 'view_model/auth_controller/auth_controller.dart';
import 'view_model/home_controller/home_controller.dart';

/// 🌙 Background Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("--- 🌙 FULL BACKGROUND NOTIFICATION ---");
  print("Message ID: ${message.messageId}");
  print("From: ${message.from}");
  print("Sent Time: ${message.sentTime}");
  
  if (message.notification != null) {
    print("Notification Title: ${message.notification?.title}");
    print("Notification Body: ${message.notification?.body}");
    print("Notification Android Image: ${message.notification?.android?.imageUrl}");
    print("Notification Apple Image: ${message.notification?.apple?.imageUrl}");
  }
  
  print("Data Payload: ${message.data}");
  print("---------------------------------------");
}

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 Lock orientations only on mobile
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// 🔥 Ad Service Init
  await AdService.init();

  /// 🔥 Meta Ads SDK Init
  FacebookEventsService.logActivatedApp();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  /// 🔥 Firebase Init
  try {
    if (kIsWeb) {
      print("🌐 Firebase Web: Attempting initialization...");
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCQjTiOSB_D9kYg2tMIN0iIjS-vbNH5ne0",
          authDomain: "mirchi-ott.firebaseapp.com",
          projectId: "mirchi-ott",
          storageBucket: "mirchi-ott.firebasestorage.app",
          messagingSenderId: "399081225701",
          appId: "1:399081225701:web:9f92eeb3b185c34ede430c",
          measurementId: "G-YEZ9EVGS3J",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print("✅ Firebase Initialized");
    
    // 🔥 Firebase Analytics: Log App Open
    FirebaseAnalyticsService.logAppOpen();
  } catch (e) {
    print("⚠️ Firebase Initialization Failed: $e");
    print("💡 Tip: For Web, make sure you have configured Firebase correctly (flutterfire configure)");
  }

  /// 🌙 Background Listener (Mobile only typically, for web it uses service workers)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// 💾 Local Storage
  await GetStorage.init();
  await Hive.initFlutter();
  await Hive.openBox('appBox');

  print("✅ Local Storage Initialized");

  /// 🌐 Network Service
  final networkService = NetworkApiService();
  Get.put<BaseApiService>(networkService, permanent: true);

  print("✅ Network Service Initialized");

  /// 🔐 Token Setup
  String? token = AppSession.getToken();

  if (token != null) {
    networkService.setToken(token);
    print("✅ Auth Token Set");
  } else {
    print("⚠️ No Auth Token Found");
  }

  /// 🔔 Notification Service (DON'T AWAIT ❌)
  Get.put(NotificationService(), permanent: true);

  print("✅ Notification Service Registered");

  /// 📦 Controllers
  Get.put(AuthController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(ContentController(), permanent: true);
  Get.put(InteractionController(), permanent: true);
  Get.put(WatchlistController(), permanent: true);

  print("✅ All Controllers Initialized");

  /// 🚀 Run App FIRST (IMPORTANT)
  runApp(const MyApp());

  /// 🔥 Initialize Notifications AFTER UI LOAD (FIX)
  if (!kIsWeb) {
    Future.delayed(const Duration(seconds: 1), () {
      print("🚀 Initializing Notification Service (Delayed)");
      NotificationService.to.init();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mirchi OTT',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
