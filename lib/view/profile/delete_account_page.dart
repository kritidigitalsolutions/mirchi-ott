import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../utils/custom_snackbar.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  bool isConfirmed = false;
  String? selectedReason;
  
  final List<String> reasons = [
    "Privacy concerns",
    "No longer using the app",
    "Found a better alternative",
    "Too many notifications",
    "Technical issues",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill if logged in
    if (authController.isLoggedIn.value) {
      _nameController.text = authController.userData.value?['name'] ?? '';
      _contactController.text = authController.userData.value?['phone'] ?? authController.userData.value?['email'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: const Text("Delete Account", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(Icons.person_remove_outlined, color: Colors.red, size: 80),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Request Account Deletion",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Please fill out this form to request the permanent deletion of your account and all associated data.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  _buildLabel("Full Name"),
                  _buildTextField(_nameController, "Enter your full name", Icons.person_outline),
                  
                  const SizedBox(height: 20),
                  _buildLabel("Phone Number or Email"),
                  _buildTextField(_contactController, "Enter registered phone or email", Icons.contact_mail_outlined),
                  
                  const SizedBox(height: 20),
                  _buildLabel("Reason for leaving"),
                  _buildDropdown(),
                  
                  if (selectedReason == "Other") ...[
                    const SizedBox(height: 20),
                    _buildLabel("Please specify"),
                    _buildTextField(_reasonController, "Tell us more...", Icons.edit_note_outlined, maxLines: 3),
                  ],
                  
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Permanent Action",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Once your account is deleted, it cannot be recovered. All your subscriptions, watchlists, and data will be permanently removed.",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: isConfirmed,
                        activeColor: Colors.red,
                        side: const BorderSide(color: Colors.white54),
                        onChanged: (value) {
                          setState(() {
                            isConfirmed = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "I confirm that I want to delete my account permanently.",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isConfirmed) ? Colors.red : Colors.grey[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isConfirmed ? _handleSubmit : null,
                      child: const Text(
                        "SUBMIT DELETION REQUEST",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) return "This field is required";
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedReason,
          dropdownColor: Colors.grey[900],
          isExpanded: true,
          hint: const Text("Select a reason", style: TextStyle(color: Colors.white30, fontSize: 14)),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          items: reasons.map((String reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(reason),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              selectedReason = value;
            });
          },
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (selectedReason == null) {
        CustomSnackbar.show(title: "Required", message: "Please select a reason", isError: true);
        return;
      }
      
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Confirm Deletion", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Are you sure you want to submit this request? Our team will process it within 24-48 hours.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Get.back(); // Close dialog
                
                // Show success and redirect
                CustomSnackbar.show(
                  title: "Request Submitted",
                  message: "Your deletion request has been received.",
                  isSuccess: true,
                );
                
                if (authController.isLoggedIn.value) {
                  await authController.logout();
                }
                
                Get.offAllNamed('/');
              },
              child: const Text("CONFIRM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}
