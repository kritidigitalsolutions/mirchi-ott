import 'package:get/get.dart';
import 'package:mirchi_ott/view/auth/otpPage.dart';
import 'package:mirchi_ott/view/auth/signInPage.dart';
import 'package:mirchi_ott/view/dramaDetails/cast_crewPage.dart';
import 'package:mirchi_ott/view/dramaDetails/dramaDetailsPage.dart';
import 'package:mirchi_ott/view/dramaDetails/topArtistpage.dart';
import 'package:mirchi_ott/view/homePages/mainHomepage.dart';
import 'package:mirchi_ott/view/notifications/notification_page.dart';
import 'package:mirchi_ott/view/popUp/redeem_voucher_page.dart';
import 'package:mirchi_ott/view/popUp/search_with_mic.dart';
import 'package:mirchi_ott/view/premium/goPremium.dart';
import 'package:mirchi_ott/view/premium/payment_screen.dart';
import 'package:mirchi_ott/view/profile/create_profile_page.dart';
import 'package:mirchi_ott/view/profile/create_ticket_page.dart';
import 'package:mirchi_ott/view/profile/help_page.dart';
import 'package:mirchi_ott/view/profile/privacy_policy_page.dart';
import 'package:mirchi_ott/view/profile/profilePage.dart';
import 'package:mirchi_ott/view/profile/refund_policy_page.dart';
import 'package:mirchi_ott/view/profile/terms_condition_page.dart';
import 'package:mirchi_ott/view/profile/ticket_chat_page.dart';
import 'package:mirchi_ott/view/profile/watchlist.dart';
import 'package:mirchi_ott/view/profile/setting_page.dart';
import 'package:mirchi_ott/view/profile/Rate_your_app.dart';
import 'package:mirchi_ott/view/profile/purchased_plans_page.dart';
import 'package:mirchi_ott/view/navbar/downloads.dart';
import 'package:mirchi_ott/view/root_page.dart';
import 'package:mirchi_ott/view/search_pages/searchPage.dart';
import 'package:mirchi_ott/view/shorts/vertical_shorts_player.dart';
import 'package:mirchi_ott/view/shorts/shorts_episodes_grid.dart';
import 'package:mirchi_ott/view/videoPlayer/video_player.dart';
import 'package:mirchi_ott/view_model/auth_controller/auth_controller.dart';
import 'package:mirchi_ott/widgets/catagory_widget.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const RootPage()),
    GetPage(name: AppRoutes.home, page: () => const RootPage()),
    GetPage(name: AppRoutes.signIn, page: () => const SignInPage()),
    GetPage(name: AppRoutes.otpPage, page: () => OtpPage(phoneNumber: Get.arguments ?? '')),
    GetPage(name: AppRoutes.createProfile, page: () => CreateProfilePage(phone: Get.arguments ?? '')),
    GetPage(name: AppRoutes.createTicket, page: () => const CreateTicketPage()),
    GetPage(name: AppRoutes.ticketChat, page: () => TicketChatPage(ticket: Get.arguments)),
    GetPage(name: AppRoutes.privacy, page: () => const PrivacyPolicyPage()),
    GetPage(name: AppRoutes.terms, page: () => const TermsAndConditionsPage()),
    GetPage(name: AppRoutes.refund, page: () => const RefundPolicyPage()),
    GetPage(name: AppRoutes.help, page: () => const HelpSupportPage()),
    GetPage(name: AppRoutes.profile, page: () => ProfilePage(onLogout: () {})),
    GetPage(name: AppRoutes.goPremium, page: () => const GoPremiumPage()),
    GetPage(name: AppRoutes.payment, page: () => const PaymentScreen()),
    GetPage(name: AppRoutes.search, page: () => const SearchPage()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationPage()),
    GetPage(name: AppRoutes.voiceSearch, page: () => const VoiceListeningPage()),
    GetPage(name: AppRoutes.redeemVoucher, page: () => RedeemVoucherPage()),
    GetPage(name: AppRoutes.watchList, page: () => const WatchlistPage()),
    GetPage(name: AppRoutes.setting, page: () => const SettingsPage()),
    GetPage(name: AppRoutes.rateApp, page: () => const ReviewPage()),
    GetPage(name: AppRoutes.purchasedPlans, page: () => const PurchasedPlansPage()),
    GetPage(name: AppRoutes.downloads, page: () => const DownloadsPage()),
    GetPage(name: AppRoutes.topArtists, page: () => TopArtistsPage()),
    GetPage(name: AppRoutes.shortsEpisodes, page: () => ShortsEpisodesGrid(drama: Get.arguments)),
    GetPage(
      name: AppRoutes.shortsPlayer,
      page: () => VerticalShortsPlayer(
        episodes: (Get.arguments as Map?)?['episodes'] ?? [],
        initialIndex: (Get.arguments as Map?)?['initialIndex'] ?? 0,
        dramaName: (Get.arguments as Map?)?['dramaName'] ?? '',
      ),
    ),

    // Named Routes for Web Stability
    GetPage(
      name: AppRoutes.categoryGrid,
      page: () => CategoryGridPage(
        title: (Get.arguments as Map?)?['title'] ?? '',
        content: (Get.arguments as Map?)?['content'] ?? [],
        isSignedIn: Get.find<AuthController>().isLoggedIn.value,
      ),
    ),
    GetPage(
      name: AppRoutes.dramaDetails,
      page: () => DramaDetailsPage(
        isSignedIn: Get.find<AuthController>().isLoggedIn.value,
        content: Get.arguments,
      ),
    ),
    GetPage(
      name: AppRoutes.castDetails,
      page: () => CastDetailsPage(
        castName: (Get.arguments as Map?)?['name'] ?? '',
        castImage: (Get.arguments as Map?)?['image'] ?? '',
      ),
    ),
    GetPage(
      name: AppRoutes.videoPlayer,
      page: () => AdvancedVideoPlayer(
        url: (Get.arguments as Map?)?['url'] ?? '',
        title: (Get.arguments as Map?)?['title'] ?? '',
      ),
    ),
  ];
}
