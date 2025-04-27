import 'package:Flui/core/shared/providers/firebase_providers.dart';
import 'package:Flui/services/chat/chat_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatServiceProvider = StateNotifierProvider<ChatService, void>((ref) {
  return ChatService(
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});
