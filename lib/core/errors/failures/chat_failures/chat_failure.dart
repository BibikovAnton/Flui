// lib/features/chat/domain/failures/chat_failures.dart
sealed class ChatFailure {
  final String message;
  const ChatFailure(this.message);

  @override
  String toString() => message;
}

// Ошибки сообщений
class MessageSendFailure extends ChatFailure {
  const MessageSendFailure(String message) : super(message);
}

class MessageGetFailure extends ChatFailure {
  const MessageGetFailure(String message) : super(message);
}

// Ошибки пользователей
class UserBlockFailure extends ChatFailure {
  const UserBlockFailure(String message) : super(message);
}

class UserUnblockFailure extends ChatFailure {
  const UserUnblockFailure(String message) : super(message);
}

class UserReportFailure extends ChatFailure {
  const UserReportFailure(String message) : super(message);
}

// Ошибки чатов
class ChatNotFoundFailure extends ChatFailure {
  const ChatNotFoundFailure(String message) : super(message);
}

class ChatDeleteFailure extends ChatFailure {
  const ChatDeleteFailure(String message) : super(message);
}

// Общие ошибки
class PermissionDeniedFailure extends ChatFailure {
  const PermissionDeniedFailure() : super('Permission denied');
}

class UnknownChatFailure extends ChatFailure {
  const UnknownChatFailure() : super('Unknown error occurred');
}
