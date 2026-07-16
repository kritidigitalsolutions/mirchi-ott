import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../view_model/profile/create_profile_controller.dart';
import '../../utils/custom_snackbar.dart';

class CreateProfilePage extends StatefulWidget {
  final String phone;

  const CreateProfilePage({super.key, required this.phone});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final AuthController authController;
  late final CreateProfileController createProfileController;
  bool isEmailAccount = false;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    createProfileController = Get.put(CreateProfileController());
    
    final user = authController.userData.value;
    nameController = TextEditingController(text: user?['name'] ?? "");
    
    // Check if the argument is a valid phone number
    bool isPhoneNumber = RegExp(r'^\+?[0-9]{10,15}$').hasMatch(widget.phone);
    isEmailAccount = !isPhoneNumber;
    
    String initialPhone = isPhoneNumber ? widget.phone : (user?['phone'] ?? "");
    // If phone in userData is dummy, clear it
    if (initialPhone.startsWith("google_") || initialPhone.length < 10) {
      initialPhone = "";
    }
    
    phoneController = TextEditingController(text: initialPhone);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: const Text("Create Profile", style: TextStyle(color: AppColors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  /// Profile Image (Optional)
                  GestureDetector(
                    onTap: createProfileController.pickImage,
                    child: Obx(() => CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: createProfileController.selectedImage.value != null
                              ? FileImage(createProfileController.selectedImage.value!)
                              : null,
                          child: createProfileController.selectedImage.value == null
                              ? const Icon(Icons.camera_alt, size: 40, color: Colors.white54)
                              : null,
                        )),
                  ),

                  TextButton(
                    onPressed: createProfileController.pickImage,
                    child: const Text(
                      "Choose Profile Picture",
                      style: TextStyle(color: AppColors.buttonColor),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Show Email if it's an email account
                  if (isEmailAccount)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        widget.phone,
                        style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),

                  const SizedBox(height: 10),

                  /// Name Field
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Phone Field (Editable if it was an email login)
                  TextField(
                    controller: phoneController,
                    enabled: isEmailAccount,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: isEmailAccount ? AppColors.white : Colors.white54),
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: authController.isLoading.value
                              ? null
                              : () async {
                                  if (nameController.text.trim().isEmpty) {
                                    CustomSnackbar.show(title: "Error", message: "Name is required", isError: true);
                                    return;
                                  }
                                  
                                  if (phoneController.text.trim().isEmpty || phoneController.text.trim().length < 10) {
                                    CustomSnackbar.show(title: "Error", message: "Valid 10-digit Phone is required", isError: true);
                                    return;
                                  }

                                  String userEmail = "";
                                  if (widget.phone.contains('@')) {
                                    userEmail = widget.phone;
                                  } else {
                                    userEmail = authController.userData.value?['email'] ?? "";
                                  }

                                  bool success = await authController.updateAndSaveProfile(
                                    name: nameController.text.trim(),
                                    email: userEmail,
                                    phone: phoneController.text.trim(),
                                    imagePath: createProfileController.selectedImage.value?.path,
                                  );

                                  if (success) {
                                    Get.offAllNamed(AppRoutes.navbar); // Navigate to home
                                  }
                                },
                          child: authController.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Save",
                                  style: TextStyle(color: AppColors.white, fontSize: 16),
                                ),
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
