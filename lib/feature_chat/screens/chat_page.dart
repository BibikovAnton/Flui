import 'package:Flui/core/shared/providers/auth_providers.dart';
import 'package:Flui/core/shared/providers/chat_providers.dart';
import 'package:Flui/feature_auth/widgets/my_textfiels.dart';
import 'package:Flui/feature_chat/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final chatMessageControllerProvider =
    Provider.autoDispose<TextEditingController>(
      (ref) => TextEditingController(),
    );

class ChatPage extends ConsumerStatefulWidget {
  final String receiverEmail;
  final String receiverId;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateUserOnlineStatus(true);
    _focusNode.addListener(_onFocusChange);
    Future.delayed(const Duration(milliseconds: 500), scrollDown);
  }

  @override
  void dispose() {
    _updateUserOnlineStatus(false);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 500), scrollDown);
    }
  }

  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    final userId = ref.read(authServiceProvider).currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final message = ref.read(chatMessageControllerProvider).text;
    if (message.isEmpty) return;

    await ref
        .read(chatServiceProvider.notifier)
        .sendMessage(widget.receiverId, message);

    ref.read(chatMessageControllerProvider).clear();
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.read(authServiceProvider).currentUser;
    final userInitial =
        currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U';

    return Scaffold(
      appBar: _buildAppBar(userInitial),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Expanded(child: _MessageList(receiverId: widget.receiverId)),
          _MessageInput(onSend: sendMessage),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String userInitial) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.receiverId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _BasicAppBarContent(
              email: widget.receiverEmail,
              initial: userInitial,
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          return _UserAppBarContent(userData: data, initial: userInitial);
        },
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }
}

class _MessageList extends ConsumerWidget {
  final String receiverId;

  const _MessageList({required this.receiverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.read(authServiceProvider).currentUser?.uid ?? '';
    final messagesStream = ref
        .read(chatServiceProvider.notifier)
        .getMessages(currentUserId, receiverId);

    return StreamBuilder<QuerySnapshot>(
      stream: messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _MessageItem(
              doc: messages[index],
              isCurrentUser: messages[index]['senderID'] == currentUserId,
            );
          },
        );
      },
    );
  }
}

class _MessageItem extends StatelessWidget {
  final DocumentSnapshot doc;
  final bool isCurrentUser;

  const _MessageItem({required this.doc, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            messageId: doc.id,
            userId: data['senderID'],
          ),
        ],
      ),
    );
  }
}

class _MessageInput extends ConsumerWidget {
  final VoidCallback onSend;

  const _MessageInput({required this.onSend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(chatMessageControllerProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: controller,
              obscureText: false,
              hinText: 'Сообщение',
            ),
          ),
          IconButton(onPressed: onSend, icon: const Icon(Icons.send)),
        ],
      ),
    );
  }
}

class _UserAppBarContent extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String initial;

  const _UserAppBarContent({required this.userData, required this.initial});

  @override
  Widget build(BuildContext context) {
    final isOnline = userData['isOnline'] as bool? ?? false;
    final lastSeen = userData['lastSeen'] as Timestamp?;

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.07,
              child: Text(initial),
            ),
            if (!isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.background,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOnline
                  ? 'в сети'
                  : 'был(а) ${lastSeen != null ? DateFormat('HH:mm').format(lastSeen.toDate()) : 'недавно'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _BasicAppBarContent extends StatelessWidget {
  final String email;
  final String initial;

  const _BasicAppBarContent({required this.email, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.07,
          child: Text(initial),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            Text(
              'статус неизвестен',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
