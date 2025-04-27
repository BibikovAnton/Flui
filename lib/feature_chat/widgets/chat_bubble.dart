import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatBubble extends ConsumerWidget {
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

  void _showOptions(
    BuildContext context,
    String messageId,
    String userID,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                title: const Text("Пожаловаться"),
                leading: const Icon(Icons.flag),
                onTap: () {
                  Navigator.pop(context);
                  _reportContent(context, messageId, userID, ref);
                },
              ),
              ListTile(
                title: const Text("Заблокировать"),
                leading: const Icon(Icons.block),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userId, ref);
                },
              ),
              ListTile(
                title: const Text("Отмена"),
                leading: const Icon(Icons.cancel),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reportContent(
    BuildContext context,
    String messageId,
    String userId,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Пожаловаться на сообщение'),
          content: const Text('Отправить жалобу на это сообщение?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                // ref
                //     .read(chatRepositoryProvider)
                //     .(
                //       reportedMessageId: messageId,
                //       reportedUserId: userId,
                //     );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Жалоба отправлена')),
                );
              },
              child: const Text('Пожаловаться'),
            ),
          ],
        );
      },
    );
  }

  void _blockUser(BuildContext context, String userId, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Блокировка пользователя'),
          content: const Text(
            'Вы уверены, что хотите заблокировать этого пользователя?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                // ref.read(chatRepositoryProvider).blockUser(userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пользователь заблокирован')),
                );
              },
              child: const Text('Заблокировать'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (!isCurrentUser) {
          _showOptions(context, messageId, userId, ref);
        }
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isCurrentUser ? Colors.green : Colors.grey,
        ),
        child: Text(message),
      ),
    );
  }
}
