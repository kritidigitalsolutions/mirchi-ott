import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/network/api_network_service.dart';
import '../../data/network/base_api_service.dart';
import '../../data/models/response_model/auth_response_model/verify_otp_response.dart';
import '../../utils/app_session.dart';
import '../../utils/notification_service.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/facebook_events_service.dart';
import '../../utils/firebase_analytics_service.dart';

class AuthController extends GetxController {
  static const String _googleWebClientId =
      '399081225701-gir0j3n161vkhk0dlrlkf9qccgv7e0gj.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;
  StreamSubscription<GoogleSignInAccount?>? _googleSignInSubscription;
  bool _isHandlingGoogleAccount = false;

  // ✅ FIX: Use late and initialize in onInit to ensure we get the global instance
  late AuthRepository repository;

  var isLoading = false.obs;
  var isGoogleLoading = false.obs;
  var isAppleLoading = false.obs;
  var isLoggedIn = false.obs;
  final nameController = TextEditingController();
  var googleLoginResponse = Rxn<VerifyOtpResponse>();
  final storage = GetStorage();
  var userData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    
    // ✅ Always use the global instance registered in main.dart
    final globalApiService = Get.find<BaseApiService>();
    repository = AuthRepository(globalApiService);
    _configureGoogleSignIn();
    
    isLoggedIn.value = AppSession.getLogin();
    var saved = storage.read('user_data');
    if (saved != null) {
      userData.value = Map<String, dynamic>.from(saved);
    }

    // Set initial token from session if available
    String? token = AppSession.getToken();
    if (token != null && token.isNotEmpty) {
      _updateGlobalToken(token);
    }
  }

  // ✅ Helper to update token in the shared service
  void _updateGlobalToken(String token) {
    final apiService = Get.find<BaseApiService>();
    if (apiService is NetworkApiService) {
      apiService.setToken(token);
    }
  }

  void _configureGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? _googleWebClientId : null,
      serverClientId: kIsWeb ? null : _googleWebClientId,
    );

    if (kIsWeb) {
      _googleSignInSubscription =
          _googleSignIn.onCurrentUserChanged.listen((googleUser) async {
        if (googleUser == null) return;
        final response = await _completeGoogleLogin(googleUser);
        if (response != null) {
          googleLoginResponse.value = response;
        }
      });
    }
  }

  Future<VerifyOtpResponse?> _completeGoogleLogin(
    GoogleSignInAccount googleUser,
  ) async {
    if (_isHandlingGoogleAccount) return null;

    _isHandlingGoogleAccount = true;
    isGoogleLoading.value = true;
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        debugPrint('Google Sign-In: idToken is null on ${kIsWeb ? 'Web' : 'mobile'}.');
        CustomSnackbar.show(
          title: 'Sign-in Failed',
          message: kIsWeb
              ? 'Google did not return an ID token. Please use the Google sign-in button and verify the Web OAuth Client ID configuration.'
              : 'Google did not return an ID token. Please verify the Android/iOS Google Sign-In configuration.',
          isError: true,
        );
        return null;
      }

      debugPrint("🚀 Sending idToken to backend...");
      final response = await repository.googleLogin(idToken);

      if (response != null && response.success) {
        if (response.token != null && response.token!.isNotEmpty) {
          await AppSession.setToken(response.token!);
          _updateGlobalToken(response.token!);
        }

        if (response.user != null) {
          userData.value = response.user;
          await storage.write('user_data', response.user);
        }

        // ✅ Silently sync numeric phone if it's a google_ ID or empty BEFORE setting login status
        await _syncNumericPhoneIfNeeded(response.user);

        // ✅ Always set login status to true for Google Login
        setLoginStatus(true);
        FacebookEventsService.logLogin(method: "google");
        FirebaseAnalyticsService.logLogin(method: "google");

        CustomSnackbar.show(
          title: 'Welcome!',
          message: 'Signed in successfully with Google',
          isSuccess: true,
        );

        return response;
      }

      final String errorMsg = response?.message ?? 'Backend authentication failed';
      debugPrint("❌ Backend Google Login Failed: $errorMsg");
      CustomSnackbar.show(
        title: 'Login Error',
        message: errorMsg,
        isError: true,
      );
      return null;
    } catch (e) {
      debugPrint("❌ Google Auth Error: $e");
      CustomSnackbar.show(
        title: 'Sign-in Failed',
        message: 'Google Sign-in failed. Please verify that this domain is added to your Google Cloud Console (OAuth Web Client ID Authorized Origins) and Firebase Console.',
        isError: true,
      );
      return null;
    } finally {
      _isHandlingGoogleAccount = false;
      isGoogleLoading.value = false;
    }
  }

  /// 🔄 Sync FCM and Fetch Notifications after Login
  void _syncNotificationsAfterLogin() {
    try {
      if (Get.isRegistered<NotificationService>()) {
        print("🔔 Syncing notifications and FCM token after login...");
        NotificationService.to.uploadToken();
        NotificationService.to.fetchNotifications();
      }
    } catch (e) {
      print("⚠️ Notification sync failed: $e");
    }
  }

  void setLoginStatus(bool status) async {
    isLoggedIn.value = status;
    await AppSession.setLogin(status);
    
    if (status) {
      String? token = AppSession.getToken();
      if (token != null) {
        _updateGlobalToken(token);
      }
      // ✅ Fetch all notifications from API when user logs in
      _syncNotificationsAfterLogin();
    }
  }

  Future<bool> sendOtp(String identifier) async {
    isLoading.value = true;
    try {
      final response = await repository.sendOtp(identifier);
      String otpMessage = 'Your OTP has been sent successfully.';
      if (response.otp != null) {
        otpMessage = 'Your OTP is: ${response.otp}';
      }
      CustomSnackbar.show(
        title: 'OTP Generated',
        message: otpMessage,
        isSuccess: true,
      );
      print(response);
      return true;
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: e.toString(),
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<VerifyOtpResponse?> verifyOtp(String phoneNumber, String otp) async {
    isLoading.value = true;
    try {
      final response = await repository.verifyOtp(phoneNumber, otp);
      if (response != null && response.success) {
        if (response.token != null) {
          await AppSession.setToken(response.token!);
          _updateGlobalToken(response.token!); // ✅ Sync token to global service
        }
        
        if (response.user != null) {
          userData.value = response.user;
          await storage.write('user_data', response.user);
        }

        // ✅ Fix: Set login status if NOT a new user (Existing user is now logged in)
        if (!response.isNewUser) {
          setLoginStatus(true);
          FacebookEventsService.logLogin(method: "otp");
          FirebaseAnalyticsService.logLogin(method: "otp");
        }

        // ✅ If logging in with Email, ensure we have a numeric dummy phone for payments
        if (phoneNumber.contains('@')) {
          await _syncNumericPhoneIfNeeded(response.user);
        }
        
        return response;
      }
      return null;
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: e.toString(),
        isError: true,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<VerifyOtpResponse?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        CustomSnackbar.show(
          title: 'Google Sign-In',
          message: 'Please use the Google sign-in button to continue.',
          isError: true,
        );
        return null;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      return _completeGoogleLogin(googleUser);
    } catch (e) {
      debugPrint("❌ Google Sign-In Exception: $e");
      String message = e.toString();

      if (message.contains("PlatformException(10,")) {
        message =
            "Google Sign-In Error (10): Please verify the Android OAuth client and SHA-1 configuration.";
      } else if (message.contains("PlatformException(12500,")) {
        message = "Google Sign-In Error (12500): Sign-in failed. Please check your Firebase configuration.";
      }
      
      CustomSnackbar.show(
        title: 'Error',
        message: message,
        isError: true,
      );
      return null;
    }
  }

  Future<void> loginWithApple() async {
    isLoading.value = true;
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final response = await repository.appleLogin({
        "idToken": credential.identityToken,
        "provider": "apple",
        "email": credential.email,
        "fullName": credential.givenName != null
            ? "${credential.givenName} ${credential.familyName}"
            : null,
      });

      final data = VerifyOtpResponse.fromJson(response);
      if (data.success == true) {
        if (data.token != null && data.token!.isNotEmpty) {
          await AppSession.setToken(data.token!);
          _updateGlobalToken(data.token!);
        }

        if (data.user != null) {
          userData.value = data.user;
          await storage.write('user_data', data.user);
        }

        if (data.user?['fullName'] != null &&
            data.user!['fullName']!.isNotEmpty) {
          nameController.text = data.user!['fullName']!;
        } else if (credential.givenName != null) {
          nameController.text =
              "${credential.givenName} ${credential.familyName}";
        }

        _syncNotificationsAfterLogin();
        await _syncNumericPhoneIfNeeded(data.user);

        FacebookEventsService.logLogin(method: "apple");
        FirebaseAnalyticsService.logLogin(method: "apple");

        if (data.isNewUser) {
          if (nameController.text.trim().length < 3) {
            Get.offAllNamed(AppRoutes.createProfile,
                arguments: data.user?['email'] ?? "");
          } else {
            setLoginStatus(true);
            Get.offAllNamed(AppRoutes.navbar);
          }
        } else {
          setLoginStatus(true);
          Get.offAllNamed(AppRoutes.navbar);
        }
      } else {
        CustomSnackbar.show(
          title: "Error",
          message: data.message ?? "Apple login failed",
          isError: true,
        );
      }
    } catch (e) {
      debugPrint("Apple Login Error: $e");
      if (!e.toString().contains("canceled")) {
        CustomSnackbar.show(
          title: "Error",
          message: "Apple login failed. Please try again.",
          isError: true,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _googleSignInSubscription?.cancel();
    nameController.dispose();
    super.onClose();
  }

  Future<bool> websiteLogin(String token) async {
    isLoading.value = true;
    try {
      await AppSession.setToken(token);
      _updateGlobalToken(token);
      
      final response = await repository.websiteLogin();
      if (response != null && response.success) {
        if (response.user != null) {
          userData.value = response.user;
          await storage.write('user_data', response.user);
        }
        setLoginStatus(true);
        FacebookEventsService.logLogin(method: "website");
        FirebaseAnalyticsService.logLogin(method: "website");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Website Login Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAndSaveProfile({
    required String name,
    required String email,
    required String phone,
    String? imagePath,
  }) async {
    try {
      isLoading.value = true;
      final response = await repository.createProfile(
        phone: phone,
        name: name,
        profileImage: imagePath,
      );

      if (response != null) {
        String? token = response['token'];
        if (token != null) {
          await AppSession.setToken(token);
          _updateGlobalToken(token); // ✅ Sync token to global service
        }

        userData.value = response['user'] ?? {"name": name, "email": email, "phone": phone};
        await storage.write('user_data', userData.value);
        
        // ✅ User is fully registered and logged in now
        setLoginStatus(true);
        FacebookEventsService.logRegistration(method: "profile_completion");
        FirebaseAnalyticsService.logRegistration(method: "profile_completion");
        return true;
      }
      return false;
    } catch (e) {
      if (e.toString().contains("Profile already completed")) {
        // If profile exists, at least update the phone number if provided
        await updatePhoneNumber(phone);
        setLoginStatus(true);
        return true;
      }
      debugPrint("❌ Create Profile Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePhoneNumber(String phone) async {
    try {
      // Use a local loading state if needed, but don't block the global one if it's a silent sync
      final response = await repository.updateProfile(phone: phone);
      if (response != null) {
        await getProfile(); // Refresh user data to get updated phone
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Update Phone Error: $e");
      return false;
    }
  }

  Future<void> getProfile() async {
    try {
      final response = await repository.getProfile();
      if (response != null && response['user'] != null) {
        userData.value = Map<String, dynamic>.from(response['user']);
        await storage.write('user_data', userData.value);
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Google Sign-Out Error: $e");
    }

    await AppSession.clearSession();
    await storage.remove('user_data');
    userData.value = null;
    googleLoginResponse.value = null;
    isLoggedIn.value = false;
    _updateGlobalToken(""); // Clear token in network service
    
    // Clear notifications locally on logout
    if (Get.isRegistered<NotificationService>()) {
      NotificationService.to.clearNotifications();
    }
  }

  Future<void> _syncNumericPhoneIfNeeded(Map<String, dynamic>? user) async {
    try {
      String currentPhone = user?['phone']?.toString() ?? "";

      // If phone is missing, or contains letters (like google_... or email_...), or isn't 10 digits
      bool isInvalid = currentPhone.isEmpty ||
          currentPhone.contains(RegExp(r'[a-zA-Z]')) ||
          currentPhone.length != 10;

      if (isInvalid) {
        debugPrint("🛠 Syncing numeric dummy phone for numeric-only API requirements...");
        String uniqueDummy = "9${DateTime.now().millisecondsSinceEpoch.toString().substring(4, 13)}";
        await updatePhoneNumber(uniqueDummy);
      }
    } catch (e) {
      debugPrint("⚠️ Failed to sync numeric phone: $e");
    }
  }
}
