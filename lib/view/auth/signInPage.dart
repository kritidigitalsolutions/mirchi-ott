import 'package:flutter/material.dart';
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

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  final FocusNode phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    /// 🔥 Auto open keyboard (important fix)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(phoneFocusNode);
      }
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,

        /// ✅ FIXED BACK BUTTON
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
            onPressed: () {
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.30,
                  ),

                  /// LOGO
                  Image.asset(
                    AppImages.logo,
                    height: 100,
                  ),

                  const SizedBox(height: 25),

                  /// TITLE
                  const Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// PHONE FIELD
                  TextFormField(
                    controller: phoneController,
                    focusNode: phoneFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone or Email is required";
                      }

                      bool isEmail = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                      ).hasMatch(value);

                      bool isPhone = RegExp(
                        r'^[6-9][0-9]{9}$',
                      ).hasMatch(value);

                      if (!isEmail && !isPhone) {
                        return "Enter valid phone number or email";
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
                      errorStyle:
                      const TextStyle(color: Colors.redAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// SIGNUP CODE TOGGLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Have a sign up code? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => showCodeField.toggle(),
                        child: const Text(
                          "Enter Code",
                          style: TextStyle(
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// CODE FIELD
                  Obx(() => showCodeField.value
                      ? TextField(
                    controller: codeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter Sign Up Code",
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                      : const SizedBox.shrink()),

                  const SizedBox(height: 20),

                  /// AGE CHECKBOX
                  Row(
                    children: [
                      Obx(() => Checkbox(
                        value: isAgeConfirmed.value,
                        activeColor: Colors.pinkAccent,
                        onChanged: (value) {
                          if (!isAgeConfirmed.value) {
                            Get.dialog(
                              AlertDialog(
                                backgroundColor: Colors.black,
                                title: const Text(
                                  "Age Restriction",
                                  style:
                                  TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  "You must be 18+ to use Mirchi OTT.",
                                  style: TextStyle(
                                      color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child:
                                    const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      isAgeConfirmed.value =
                                      true;
                                      Get.back();
                                    },
                                    child:
                                    const Text("Confirm"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            isAgeConfirmed.value = false;
                          }
                        },
                      )),
                      const Expanded(
                        child: Text(
                          "I confirm that I am 18+ years old",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// GET OTP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Obx(() => ElevatedButton(
                      onPressed: (isAgeConfirmed.value &&
                          !authController
                              .isLoading.value)
                          ? () async {
                        if (_formKey.currentState!
                            .validate()) {
                          FocusManager.instance.primaryFocus
                              ?.unfocus();

                          String valueToSend =
                              "+91${phoneController.text}";

                          bool success =
                          await authController
                              .sendOtp(valueToSend);

                          if (success) {
                            Get.to(() => OtpPage(
                              phoneNumber:
                              valueToSend,
                            ));
                          }
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.buttonColor,
                        disabledBackgroundColor:
                        Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: authController.isLoading.value
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        "Get OTP",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
