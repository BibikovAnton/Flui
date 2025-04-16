import 'package:chatty/commponents/user_tile.dart';
import 'package:chatty/services/auth/auth_services.dart';
import 'package:chatty/services/chat/chat_services.dart';
import 'package:flutter/material.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  final ChatService _chatService = ChatService();
  final AuthServices _authServices = AuthServices();

  void _showUnblockBox(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  _chatService.unblockUser(userId);
                  Navigator.pop(context);
                },
                child: Text('UnBlocked'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
            title: const Text('UnBlock user'),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userId = _authServices.getCurrentUser()!.uid;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getBlockedUserStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final blockedUsers = snapshot.data ?? [];

          if (blockedUsers.isEmpty) {
            return const Text('No blocked Users');
          }

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                text: user['email'],
                onTap: () => _showUnblockBox(context, user['uid']),
              );
            },
          );
        },
      ),
    );
  }
}
