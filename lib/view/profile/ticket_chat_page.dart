import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/support_controller/support_controller.dart';

class TicketChatPage extends StatefulWidget {
  final dynamic ticket;
  const TicketChatPage({super.key, required this.ticket});

  @override
  State<TicketChatPage> createState() => _TicketChatPageState();
}

class _TicketChatPageState extends State<TicketChatPage> {
  final SupportController supportController = Get.find<SupportController>();
  final TextEditingController replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    supportController.fetchTicketMessages(widget.ticket['_id']);
  }

  @override
  void dispose() {
    replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Conversation",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "ID: ${widget.ticket['_id'].toString().substring(widget.ticket['_id'].toString().length - 8)}",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Divider(color: Colors.white12, height: 1),
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
                      const Icon(Icons.message_outlined, color: Colors.white10, size: 60),
                      const SizedBox(height: 10),
                      const Text("No messages yet", style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                );
              }

              // Auto scroll to bottom when new messages arrive
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['message'] ?? "",
                            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatMessageTime(msg['createdAt']),
                            style: TextStyle(
                              color: isUser ? Colors.white70 : Colors.white38, 
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.5),
              border: const Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Type a reply...",
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    if (replyController.text.trim().isEmpty) return;
                    String text = replyController.text.trim();
                    replyController.clear();
                    bool success = await supportController.replyToTicket(widget.ticket['_id'], text);
                    if (!success) {
                      // Optionally handle error
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.buttonColor, 
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
