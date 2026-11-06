import 'package:marketers/models/chat_models.dart';
import 'package:marketers/config/mock_data_config.dart';
import 'package:marketers/mock_data/mock_chat_data.dart';
import 'package:marketers/service/api_client.dart';

class ChatPage {
  const ChatPage({required this.messages, required this.nextPage});
  final List<ChatMessage> messages;
  final String? nextPage;
}

/// Assumed REST contract until the backend chat app exposes its routes:
/// /marketer/conversations/ and /marketer/conversations/{id}/messages/.
class BackendChatRepository {
  BackendChatRepository(this._client);

  final ApiClient _client;

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _client.get('/marketer/conversations/', queryParameters: const {'page_size': 100});
      final entries = _items(response.data, aliases: const ['conversations']);
      return entries.map(ConversationMapper.fromJson).toList();
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('chat conversations', error);
      return MockChatData.conversations();
    }
  }

  Future<ChatPage> getMessages(String conversationId, {String? page}) async {
    try {
      final response = page == null
          ? await _client.get('/marketer/conversations/$conversationId/messages/', queryParameters: const {'page_size': 50})
          : await _client.get(page);
      final body = _map(response.data);
      return ChatPage(messages: _items(body, aliases: const ['messages']).map(ChatMessageMapper.fromJson).toList(), nextPage: body['next']?.toString());
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('chat messages', error);
      return ChatPage(messages: MockChatData.messagesFor(conversationId), nextPage: null);
    }
  }

  Future<ChatMessage> sendMessage(String conversationId, String content) async {
    try {
      final response = await _client.post('/marketer/conversations/$conversationId/messages/', data: {'content': content});
      return ChatMessageMapper.fromJson(_map(response.data));
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('chat send', error);
      return ChatMessage(id: 'mock-message-${DateTime.now().microsecondsSinceEpoch}', content: content, sentAt: DateTime.now(), isMine: true, status: 'sent');
    }
  }

  Future<void> markAsRead(String conversationId) async {
    if (conversationId.startsWith('mock-')) return;
    try {
      await _client.patch('/marketer/conversations/$conversationId/read/');
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('chat mark read', error);
    }
  }

  static List<Map<String, dynamic>> _items(dynamic value, {List<String> aliases = const []}) {
    if (value is List) return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    final body = _map(value);
    dynamic items = body['results'];
    for (final alias in aliases) {
      if (items == null && body.containsKey(alias)) items = body[alias];
    }
    items ??= const [];
    if (items is! List) throw const ApiFailure(ApiFailureKind.response, 'The chat response was invalid.');
    return items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : throw const ApiFailure(ApiFailureKind.response, 'The chat response was invalid.');
}

class ConversationMapper {
  static Conversation fromJson(Map<String, dynamic> json) {
    final contact = json['contact'] is Map ? Map<String, dynamic>.from(json['contact'] as Map) : json['other_participant'] is Map ? Map<String, dynamic>.from(json['other_participant'] as Map) : const <String, dynamic>{};
    final lastMessage = json['last_message'] is Map ? Map<String, dynamic>.from(json['last_message'] as Map) : const <String, dynamic>{};
    return Conversation(
      id: json['id']?.toString() ?? '',
      contactId: json['contact_id']?.toString() ?? contact['id']?.toString() ?? '',
      contactName: json['contact_name']?.toString() ?? contact['name']?.toString() ?? '${contact['first_name'] ?? ''} ${contact['last_name'] ?? ''}'.trim(),
      lastMessage: json['last_message_preview']?.toString() ?? lastMessage['content']?.toString() ?? '',
      lastMessageAt: _date(json['last_message_at'] ?? lastMessage['created_at']),
      unreadCount: _int(json['unread_count']),
      isOnline: json['is_online'] == true || contact['is_online'] == true,
      avatarUrl: json['avatar_url']?.toString() ?? contact['avatar']?.toString(),
    );
  }
}

class ChatMessageMapper {
  static ChatMessage fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id']?.toString() ?? '',
    content: json['content']?.toString() ?? json['message']?.toString() ?? '',
    sentAt: _date(json['created_at'] ?? json['sent_at']) ?? DateTime.now(),
    isMine: json['is_mine'] == true || json['sender_type']?.toString() == 'marketer',
    status: json['status']?.toString() ?? 'sent',
    imageUrl: json['image_url']?.toString() ??
        json['attachment_url']?.toString() ??
        (json['attachment'] is Map
            ? (json['attachment'] as Map)['url']?.toString()
            : null),
  );
}

DateTime? _date(dynamic value) => value == null ? null : DateTime.tryParse(value.toString())?.toLocal();
int _int(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
