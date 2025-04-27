import 'dart:async';

import 'package:Flui/commponents/my_divider.dart';
import 'package:Flui/core/shared/providers/auth_providers.dart';
import 'package:Flui/core/shared/providers/chat_providers.dart';
import 'package:Flui/feature_chat/widgets/user_tile.dart';
import 'package:animation_search_bar/animation_search_bar.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedUsersSearchQueryProvider = StateProvider<String>((ref) => '');

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(blockedUsersSearchQueryProvider);
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не авторизован')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Заблокированные пользователи'),
        actions: [_buildSearchBar(ref, context)],
      ),
      body: _BlockedUsersList(
        userId: currentUser.uid,
        searchQuery: searchQuery,
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref, BuildContext context) {
    final searchController = TextEditingController();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: AnimationSearchBar(
        hintText: 'Поиск ...',
        cursorColor: Colors.grey,
        centerTitle: 'Blocked Users',
        searchBarWidth: MediaQuery.of(context).size.width * 0.85,
        onChanged: (text) {
          ref.read(blockedUsersSearchQueryProvider.notifier).state = text;
        },
        searchTextEditingController: searchController,
        horizontalPadding: 5,
        isBackButtonVisible: false,
      ),
    );
  }
}

class _BlockedUsersList extends ConsumerWidget {
  final String userId;
  final String searchQuery;

  const _BlockedUsersList({required this.userId, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ref.read(chatServiceProvider.notifier);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatService.getBlockedUserStream(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final blockedUsers = snapshot.data ?? [];
        final filteredUsers =
            blockedUsers.where((userData) {
              final email = userData['email']?.toString().toLowerCase() ?? '';
              final query = searchQuery.toLowerCase();
              return email.contains(query);
            }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(child: Text('Нет заблокированных пользователей'));
        }

        return ListView.separated(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _BlockedUserTile(user: user);
          },
          separatorBuilder:
              (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.2,
                ),
                child: const MyDivider(),
              ),
        );
      },
    );
  }
}

class _BlockedUserTile extends ConsumerWidget {
  final Map<String, dynamic> user;

  const _BlockedUserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ref.read(chatServiceProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        trailing: GestureDetector(
          onTap: () => _showUnblockDialog(context, ref, user['uid']),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.1,
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add_alt_1),
          ),
        ),
        leading: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.07,
          child: Text(user['email'][0].toUpperCase()),
        ),
        title: UserTile(text: user['email']),
        onTap: () => _showUnblockDialog(context, ref, user['uid']),
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Разблокировать пользователя?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(chatServiceProvider.notifier)
                      .unblockUser(userId);
                  Navigator.pop(context);
                },
                child: const Text('Разблокировать'),
              ),
            ],
          ),
    );
  }
}
