import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/app_images.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import 'otpPage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();

  final isAgeConfirmed = false.obs;
  final showCodeField = false.obs;
  final isOtpMode = false.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Get.back();
            },
          ),
        ),
        body: SafeArea(
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
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  Obx(() => !isOtpMode.value
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () => isOtpMode.value = true,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttonColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Login For Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                          ],
                        )
                      : Column(
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
                            
                            /// AGE CHECKBOX
                            _buildAgeCheckbox(),
                            
                            const SizedBox(height: 20),
                            
                            /// GET OTP BUTTON
                            _buildGetOtpButton(),

                            const SizedBox(height: 25),
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white24)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text("OR", style: TextStyle(color: Colors.white54)),
                                ),
                                Expanded(child: Divider(color: Colors.white24)),
                              ],
                            ),
                            const SizedBox(height: 25),

                            /// LOGIN WITH EMAIL (GOOGLE STYLE)
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _showEmailPicker();
                                },
                                icon: const Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Login with Email",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
            const Text("Login with Email", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      Get.to(() => OtpPage(phoneNumber: email));
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

  Widget _buildAgeCheckbox() {
    return Row(
      children: [
        Obx(() => Checkbox(
              value: isAgeConfirmed.value,
              activeColor: AppColors.primary,
              onChanged: (value) => isAgeConfirmed.value = value!,
            )),
        const Expanded(
          child: Text("I confirm that I am 18+ years old", style: TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildGetOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Obx(() => ElevatedButton(
            onPressed: (isAgeConfirmed.value && !authController.isLoading.value)
                ? () async {
                    if (_formKey.currentState!.validate()) {
                      String valueToSend = "+91${phoneController.text.trim()}";
                      bool success = await authController.sendOtp(valueToSend);
                      if (success) Get.to(() => OtpPage(phoneNumber: valueToSend));
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
