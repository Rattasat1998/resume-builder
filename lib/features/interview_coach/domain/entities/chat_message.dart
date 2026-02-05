import 'package:equatable/equatable.dart';

/// Represents a single message in the interview chat
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai(
    String content, {
    MessageType type = MessageType.text,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      type: type,
    );
  }

  @override
  List<Object?> get props => [id, content, isUser, timestamp, type];
}

enum MessageType { text, question, feedback, systemMessage }
