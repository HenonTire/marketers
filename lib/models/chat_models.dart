class Conversation {
  const Conversation({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.isOnline,
    this.avatarUrl,
  });

  final String id;
  final String contactId;
  final String contactName;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isOnline;
  final String? avatarUrl;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.sentAt,
    required this.isMine,
    required this.status,
    this.imageUrl,
  });

  final String id;
  final String content;
  final DateTime sentAt;
  final bool isMine;
  final String status;
  final String? imageUrl;
}
