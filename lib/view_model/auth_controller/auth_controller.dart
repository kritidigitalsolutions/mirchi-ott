import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/network/api_network_service.dart';
import '../../data/network/base_api_service.dart';
import '../../data/models/response_model/auth_response_model/verify_otp_response.dart';
import '../../utils/app_session.dart';
import '../../utils/notification_service.dart';
import '../../utils/custom_snackbar.dart';

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
  var isLoggedIn = false.obs;
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

        final bool isComplete = !response.isNewUser &&
            (response.user != null && response.user!['phone'] != null);

        if (isComplete) {
          setLoginStatus(true);
          CustomSnackbar.show(
            title: 'Welcome!',
            message: 'Signed in successfully with Google',
            isSuccess: true,
          );
        }

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

  @override
  void onClose() {
    _googleSignInSubscription?.cancel();
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
        return true;
      }
      return false;
    } catch (e) {
      if (e.toString().contains("Profile already completed")) {
        setLoginStatus(true);
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
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
}
