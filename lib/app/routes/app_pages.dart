import 'package:get/get.dart';
import '../../view/auth/otpPage.dart';
import '../../view/auth/signInPage.dart';
import '../../view/homePages/mainHomepage.dart';
import '../../view/profile/create_ticket_page.dart';
import '../../view/profile/ticket_chat_page.dart';
import '../../view/profile/privacy_policy_page.dart';
import '../../view/profile/terms_condition_page.dart';
import '../../view/profile/refund_policy_page.dart';
import '../../view/profile/help_page.dart';
import '../../view/profile/profilePage.dart';
import '../../view/root_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const RootPage()),
    GetPage(name: AppRoutes.signIn, page: () => const SignInPage()),
    GetPage(name: AppRoutes.otpPage, page: () => const OtpPage(phoneNumber: '')),
    GetPage(name: AppRoutes.createTicket, page: () => const CreateTicketPage()),
    GetPage(name: AppRoutes.ticketChat, page: () => TicketChatPage(ticket: Get.arguments)),
    GetPage(name: AppRoutes.privacy, page: () => const PrivacyPolicyPage()),
    GetPage(name: AppRoutes.terms, page: () => const TermsAndConditionsPage()),
    GetPage(name: AppRoutes.refund, page: () => const RefundPolicyPage()),
    GetPage(name: AppRoutes.help, page: () => const HelpSupportPage()),
    GetPage(name: AppRoutes.profile, page: () => ProfilePage(onLogout: () {})),
  ];
}
