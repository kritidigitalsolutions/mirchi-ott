import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/support_controller/support_controller.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final SupportController supportController = Get.find<SupportController>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    if (supportController.categories.isNotEmpty) {
      selectedCategory = supportController.categories.first;
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
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
        title: const Text(
          "New Support Ticket",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fill in the details below to raise a ticket",
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 25),
            
            _buildLabel("Select Category"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  dropdownColor: Colors.grey[900],
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  items: supportController.categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            _buildLabel("Subject"),
            TextField(
              controller: subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Enter a brief title"),
            ),
            
            const SizedBox(height: 20),
            _buildLabel("Describe Your Issue"),
            TextField(
              controller: messageController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Provide more details here..."),
            ),
            
            const SizedBox(height: 20),
            _buildLabel("Attachments (Optional)"),
            Obx(() => Column(
              children: [
                if (supportController.selectedFilePaths.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: supportController.selectedFilePaths.length,
                      itemBuilder: (context, index) {
                        String path = supportController.selectedFilePaths[index];
                        String fileName = path.split('/').last;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, color: Colors.white54, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                                onPressed: () => supportController.removeFile(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                InkWell(
                  onTap: () => supportController.pickFiles(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.buttonColor.withOpacity(0.3), style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cloud_upload_outlined, color: AppColors.buttonColor, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Upload Attachment",
                          style: TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
            
            const SizedBox(height: 40),
            Obx(() => ElevatedButton(
              onPressed: supportController.isLoading.value ? null : () async {
                if (subjectController.text.trim().isEmpty || messageController.text.trim().isEmpty) {
                  Get.snackbar(
                    "Error", 
                    "Please fill all fields", 
                    colorText: Colors.white, 
                    backgroundColor: Colors.redAccent.withOpacity(0.8)
                  );
                  return;
                }
                
                bool success = await supportController.createTicket(
                  subjectController.text.trim(), 
                  messageController.text.trim(), 
                  selectedCategory ?? "General"
                );
                
                if (success) {
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              child: supportController.isLoading.value 
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "SUBMIT TICKET", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                        letterSpacing: 1.2
                      )
                    ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.buttonColor, width: 1)),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}
