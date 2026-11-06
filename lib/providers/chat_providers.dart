import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/chat_models.dart';
import 'package:marketers/providers/profile_providers.dart';
import 'package:marketers/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<BackendChatRepository>((ref) => BackendChatRepository(ref.watch(apiClientProvider)));
final chatSearchQueryProvider = StateProvider<String>((ref) => '');

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() => ref.watch(chatRepositoryProvider).getConversations();
  Future<void> refresh() async => state = await AsyncValue.guard(() => ref.read(chatRepositoryProvider).getConversations());
}

final conversationsProvider = AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(ConversationsNotifier.new);

final filteredConversationsProvider = Provider<AsyncValue<List<Conversation>>>((ref) {
  final conversations = ref.watch(conversationsProvider);
  final query = ref.watch(chatSearchQueryProvider).trim().toLowerCase();
  return conversations.whenData((items) => query.isEmpty ? items : items.where((item) => item.contactName.toLowerCase().contains(query) || item.lastMessage.toLowerCase().contains(query)).toList());
});

class MessagesNotifier extends FamilyAsyncNotifier<List<ChatMessage>, String> {
  String? _nextPage;
  late String _conversationId;

  @override
  Future<List<ChatMessage>> build(String conversationId) async {
    _conversationId = conversationId;
    final page = await ref.watch(chatRepositoryProvider).getMessages(conversationId);
    _nextPage = page.nextPage;
    return page.messages;
  }

  Future<void> refresh() async {
    final page = await ref.read(chatRepositoryProvider).getMessages(_conversationId);
    _nextPage = page.nextPage;
    state = AsyncData(page.messages);
  }

  Future<void> loadOlder() async {
    final current = state.valueOrNull;
    if (current == null || _nextPage == null) return;
    final page = await ref.read(chatRepositoryProvider).getMessages(_conversationId, page: _nextPage);
    _nextPage = page.nextPage;
    state = AsyncData([...current, ...page.messages]);
  }

  Future<void> send(String content) async {
    final current = state.valueOrNull ?? const [];
    final optimistic = ChatMessage(id: 'local-${DateTime.now().microsecondsSinceEpoch}', content: content, sentAt: DateTime.now(), isMine: true, status: 'sent');
    state = AsyncData([optimistic, ...current]);
    try {
      final message = await ref.read(chatRepositoryProvider).sendMessage(_conversationId, content);
      state = AsyncData([message, ...current]);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final messagesProvider = AsyncNotifierProvider.family<MessagesNotifier, List<ChatMessage>, String>(MessagesNotifier.new);
