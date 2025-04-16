import 'package:chatty/services/chat/chat_services.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageId,
    required this.userId,
  });
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;

  void _showOptions(BuildContext context, String messageId, String userID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                title: Text("Report"),
                leading: const Icon(Icons.flag),
                onTap: () {
                  Navigator.pop(context);
                  _reportContent(context, messageId, userID);
                },
              ),
              ListTile(
                title: Text("Block"),
                leading: const Icon(Icons.block),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userId);
                },
              ),
              ListTile(
                title: Text("Cancel"),
                leading: const Icon(Icons.cancel),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reportContent(BuildContext context, String messageId, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Report Message'),
          content: Text('Send Message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('cancel'),
            ),
            TextButton(
              onPressed: () {
                ChatService().reportUser(messageId, userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Message Report')));
              },
              child: Text('report'),
            ),
          ],
        );
      },
    );
  }

  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Block User'),
          content: Text('Block user sure??'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('cancel'),
            ),
            TextButton(
              onPressed: () {
                ChatService().blockUser(userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('User Blocked')));
              },
              child: Text('blocked'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isCurrentUser ? Colors.green : Colors.grey,
        ),
        child: Text(message),
      ),
    );
  }
}
