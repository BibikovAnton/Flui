import 'package:chatty/pages/chat_page.dart';
import 'package:chatty/commponents/user_tile.dart';
import 'package:chatty/pages/drawing_board_page.dart';
import 'package:chatty/services/auth/auth_services.dart';
import 'package:chatty/commponents/my_drawer.dart';
import 'package:chatty/services/chat/chat_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthServices _authFirebase = AuthServices();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      drawer: MyDrawer(),
      body: buildUserList(),
    );
  }

  Widget buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children:
              snapshot.data!
                  .map<Widget>(
                    (userData) => _buildUserListItem(userData, context),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    if (userData['email'] != _authFirebase.getCurrentUser()!.email) {
      return UserTile(
        text: userData['email'],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    recrveEmail: userData['email'],
                    receiverId: userData['uid'],
                  ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
