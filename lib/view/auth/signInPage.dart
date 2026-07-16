import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/app_images.dart';
import 'package:mirchi_ott/utils/google_sign_in_web_button.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/response_model/auth_response_model/verify_otp_response.dart';
import '../../view_model/auth_controller/auth_controller.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();
  Worker? _googleLoginWorker;

  final showCodeField = false.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      authController.googleLoginResponse.value = null;
      _googleLoginWorker =
          ever<VerifyOtpResponse?>(authController.googleLoginResponse,
              (response) {
        if (response != null) {
          _handleGoogleLoginResponse(response);
        }
      });
    }
  }

  @override
  void dispose() {
    _googleLoginWorker?.dispose();
    phoneController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: Responsive.backButton(context, onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.back();
          }),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      Image.asset(AppImages.logo, height: 100),
                      const SizedBox(height: 25),
                      const Text(
                        "Welcome",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          Column(
                            children: [
                              TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Phone is required";
                                  }
                                  if (value.length != 10) {
                                    return "Phone number must be 10 digits";
                                  }
                                  if (!RegExp(r'^[6789]').hasMatch(value)) {
                                    return "Number must start with 6, 7, 8, or 9";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixText: "+91 ",
                                  prefixStyle: const TextStyle(color: Colors.white),
                                  hintText: "Phone Number",
                                  hintStyle: const TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.grey[900],
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                              const SizedBox(height: 20),

                              /// GET OTP BUTTON
                              _buildGetOtpButton(),
                            ],
                          ),
                          const SizedBox(height: 25),
                          const Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white24)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR",
                                    style: TextStyle(color: Colors.white54)),
                              ),
                              Expanded(child: Divider(color: Colors.white24)),
                            ],
                          ),
                          const SizedBox(height: 25),

                          /// LOGIN WITH GOOGLE
                          _buildGoogleSignInButton(),

                          const SizedBox(height: 15),
                          // TextButton(
                          //   onPressed: _showEmailPicker,
                          //   child: const Text(
                          //     "Login with Email",
                          //     style: TextStyle(
                          //       color: Colors.white70,
                          //       decoration: TextDecoration.underline,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    if (kIsWeb) {
      return SizedBox(
        width: double.infinity,
        height: 55,
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildGoogleSignInWebButton(),
            Obx(() {
              if (!authController.isGoogleLoading.value) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.black.withValues(alpha: 0.45),
                alignment: Alignment.center,
                child: const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Obx(() => ElevatedButton(
            onPressed: authController.isGoogleLoading.value
                ? null
                : () async {
                    final response = await authController.signInWithGoogle();
                    if (response != null) {
                      _handleGoogleLoginResponse(response);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white12),
              ),
            ),
            child: authController.isGoogleLoading.value
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.g_mobiledata,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          )),
    );
  }

  void _handleGoogleLoginResponse(VerifyOtpResponse response) {
    if (response.isNewUser) {
      Get.offAllNamed(AppRoutes.createProfile,
          arguments: response.user?['email'] ?? "");
    } else {
      Get.offAllNamed(AppRoutes.navbar);
    }
  }

  void _showEmailPicker() {
    final TextEditingController emailPicker = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Text("Login with Email", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            AutofillGroup(
              child: TextFormField(
                controller: emailPicker,
                autofocus: true,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Select or type email",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
                onPressed: () async {
                  if (emailPicker.text.contains('@')) {
                    String email = emailPicker.text.trim();
                    Get.back();
                    await Future.delayed(const Duration(milliseconds: 250));
                    bool success = await authController.sendOtp(email);
                    if (success) {
                      Get.toNamed(AppRoutes.otpPage, arguments: email);
                    }
                  } else {
                    Get.snackbar("Error", "Please enter a valid email", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
                child: const Text("Continue", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildGetOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Obx(() => ElevatedButton(
            onPressed: (!authController.isLoading.value)
                ? () async {
                    if (_formKey.currentState!.validate()) {
                      String valueToSend = "+91${phoneController.text.trim()}";
                      bool success = await authController.sendOtp(valueToSend);
                      if (success) Get.toNamed(AppRoutes.otpPage, arguments: valueToSend);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: authController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Get OTP", style: TextStyle(fontSize: 16, color: Colors.white)),
          )),
    );
  }
}
