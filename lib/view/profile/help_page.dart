import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirchi_ott/app/routes/app_routes.dart';
import 'package:mirchi_ott/utils/responsive.dart';
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
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: const Text(
          "Help & Support",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
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
                          onTap: () => Get.toNamed(AppRoutes.createTicket),
                          color: AppColors.buttonColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.phone_in_talk_outlined,
                          label: "Call Customer Care",
                          onTap: () => _makePhoneCall("+91 8369720507"),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Contact Us Directly",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => launchUrl(Uri.parse("mailto:themirchipost@gmail.com")),
                          child: const Text(
                            "Mail - themirchipost@gmail.com",
                            style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Call - +91 8369720507",
                          style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          "(Mon - Sat 12pm - 8pm)",
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
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
      onTap: () => Get.toNamed(AppRoutes.ticketChat, arguments: ticket),
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
}
