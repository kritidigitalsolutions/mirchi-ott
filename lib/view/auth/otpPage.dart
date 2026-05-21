import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../profile/create_profile_page.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../view_model/auth_controller/otp_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../utils/custom_snackbar.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final AuthController authController;
  late final OtpController otpController;
  
  final List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    otpController = Get.put(OtpController());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void verifyOtp() async {
    String otp = controllers.map((e) => e.text).join();

    if (otp.length < 6) {
      CustomSnackbar.show(title: 'Error', message: 'Please enter 6-digit OTP', isError: true);
      return;
    }

    final response = await authController.verifyOtp(widget.phoneNumber, otp);

    if (response != null && response.success) {
      authController.setLoginStatus(true);
      
      bool isNew = response.isNewUser;
      bool isProfileIncomplete = (response.user != null && response.user!['profileComplete'] == false);

      // ✅ Unfocus before navigating
      FocusManager.instance.primaryFocus?.unfocus();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        if (isNew || isProfileIncomplete) {
          Get.offAll(() => CreateProfilePage(phone: widget.phoneNumber));
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Verify OTP",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter the OTP sent to ${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.grey,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                        if (value.length == 1 && index == 5) {
                           FocusManager.instance.primaryFocus?.unfocus();
                           verifyOtp();
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: authController.isLoading.value ? null : verifyOtp,
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Verify",
                          style: TextStyle(fontSize: 16, color: AppColors.white),
                        ),
                )),
              ),

              const SizedBox(height: 20),

              Center(
                child: Obx(() => TextButton(
                  onPressed: (otpController.isResendButtonDisabled.value || authController.isLoading.value)
                      ? null
                      : () async {
                          bool success = await authController.sendOtp(widget.phoneNumber);
                          if (success) {
                            otpController.startTimer();
                          }
                        },
                  child: Text(
                    otpController.isResendButtonDisabled.value
                        ? 'Resend OTP in ${otpController.countdown.value}\s'
                        : 'Resend OTP',
                    style: TextStyle(
                        color: otpController.isResendButtonDisabled.value
                            ? Colors.grey
                            : AppColors.buttonColor),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
