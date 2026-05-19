import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late final TextEditingController emailController;
  late final AuthController authController;
  late final CreateProfileController createProfileController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    authController = Get.find<AuthController>();
    createProfileController = Get.put(CreateProfileController());
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Create Profile", style: TextStyle(color: AppColors.white)),
        centerTitle: true,
      ),
      body: Padding(
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

              const SizedBox(height: 20),

              /// Name Field
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: "Name",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// Dynamic Field (Email if phone used, or nothing if email used)
              if (!widget.phone.contains('@')) ...[
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: "Email (Optional)",
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
              ] else ...[
                 const SizedBox(height: 15),
              ],

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

                          bool success = await authController.updateAndSaveProfile(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phone: widget.phone.contains('@') ? "" : widget.phone,
                            imagePath: createProfileController.selectedImage.value?.path,
                          );

                          if (success) {
                            Get.offAllNamed('/'); // Navigate to home
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
    );
  }
}
