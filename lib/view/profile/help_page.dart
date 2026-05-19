import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirchi_ott/view_model/support_controller/support_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/profile/privacy_controller.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final PrivacyController privacyController = Get.put(PrivacyController());
  final SupportController supportController = Get.put(SupportController());

  @override
  void initState() {
    super.initState();
    privacyController.fetchHelpData();
    supportController.fetchTickets();
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar("Error", "Could not launch dialer", colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Help & Support",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔹 Support Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.confirmation_number_outlined,
                          label: "Raise Support Ticket",
                          onTap: () => _showCreateTicketBottomSheet(),
                          color: AppColors.buttonColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.phone_in_talk_outlined,
                          label: "Call Customer Care",
                          onTap: () => _makePhoneCall("+911234567890"),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 🔹 User Tickets Section
            Obx(() {
              if (supportController.tickets.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "Recent Support Tickets",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: supportController.tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = supportController.tickets[index];
                        return _buildTicketItem(ticket);
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const Divider(color: Colors.white12, thickness: 1, indent: 16, endIndent: 16),

            /// 🔹 FAQ Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Frequently Asked Questions",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Obx(() {
              if (privacyController.isLoadingHelp.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (privacyController.helpData.isEmpty) {
                return const Center(
                  child: Text("No FAQ Found", style: TextStyle(color: Colors.white54)),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: privacyController.helpData.length,
                itemBuilder: (context, index) {
                  final help = privacyController.helpData[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        help['question'] ?? "",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      iconColor: AppColors.buttonColor,
                      collapsedIconColor: Colors.white54,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            help['answer'] ?? "",
                            style: const TextStyle(color: Colors.white70, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketItem(dynamic ticket) {
    String status = ticket['status'] ?? 'OPEN';
    Color statusColor = status == 'OPEN' ? Colors.green : (status == 'PENDING' ? Colors.orange : Colors.grey);
    
    String formattedDate = "";
    try {
       DateTime date = DateTime.parse(ticket['createdAt']);
       formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch(e) {}

    return InkWell(
      onTap: () => _showTicketDetailsBottomSheet(ticket),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(formattedDate, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket['subject'] ?? "",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              ticket['category'] ?? "",
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              ticket['lastMessage'] ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTicketBottomSheet() {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    String selectedCategory = supportController.categories.first;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 25),
                  const Text("New Support Ticket", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text("Fill in the details below to raise a ticket", style: TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 25),
                  
                  _buildLabel("Select Category"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
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
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Provide more details here..."),
                  ),
                  
                  const SizedBox(height: 35),
                  Obx(() => ElevatedButton(
                    onPressed: supportController.isLoading.value ? null : () async {
                      if (subjectController.text.isEmpty || messageController.text.isEmpty) {
                        Get.snackbar("Error", "Please fill all fields", colorText: Colors.white, backgroundColor: Colors.redAccent.withOpacity(0.8));
                        return;
                      }
                      bool success = await supportController.createTicket(subjectController.text, messageController.text, selectedCategory);
                      if (success) Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: supportController.isLoading.value 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("SUBMIT TICKET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                  )),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        }
      ),
      isScrollControlled: true,
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

  void _showTicketDetailsBottomSheet(dynamic ticket) {
    final TextEditingController replyController = TextEditingController();
    supportController.fetchTicketMessages(ticket['_id']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Conversation", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("ID: ${ticket['_id'].toString().substring(ticket['_id'].toString().length - 8)}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Get.back()),
              ],
            ),
            const Divider(color: Colors.white12, height: 30),
            
            Expanded(
              child: Obx(() {
                if (supportController.isMessagesLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
                }

                if (supportController.ticketMessages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message_outlined, color: Colors.white10, size: 50),
                        const SizedBox(height: 10),
                        const Text("No messages yet", style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: supportController.ticketMessages.length,
                  itemBuilder: (context, index) {
                    final msg = supportController.ticketMessages[index];
                    bool isUser = msg['senderType'] == 'USER';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.buttonColor : Colors.white10,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: Radius.circular(isUser ? 15 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 15),
                          ),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['message'] ?? "",
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatMessageTime(msg['createdAt']),
                              style: TextStyle(color: isUser ? Colors.white70 : Colors.white38, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a reply...",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    if (replyController.text.isEmpty) return;
                    bool success = await supportController.replyToTicket(ticket['_id'], replyController.text);
                    if (success) {
                      replyController.clear();
                      // The controller now automatically updates ticketMessages from the reply response
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.buttonColor, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.send, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatMessageTime(String? dateStr) {
    if (dateStr == null) return "";
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return "";
    }
  }
}
