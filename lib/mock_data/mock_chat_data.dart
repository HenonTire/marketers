import 'package:marketers/models/chat_models.dart';

class MockChatData {
  MockChatData._();

  static List<Conversation> conversations() {
    final now = DateTime.now();
    return [
      Conversation(id: 'mock-conversation-1', contactId: 'mock-contact-1', contactName: 'Hana Tesfaye', lastMessage: 'Thank you, I will share the campaign link today.', lastMessageAt: now.subtract(const Duration(minutes: 8)), unreadCount: 2, isOnline: true, avatarUrl: 'https://i.pravatar.cc/150?img=47'),
      Conversation(id: 'mock-conversation-2', contactId: 'mock-contact-2', contactName: 'Dawit Bekele', lastMessage: 'The new order is confirmed.', lastMessageAt: now.subtract(const Duration(hours: 2)), unreadCount: 0, isOnline: false, avatarUrl: 'https://i.pravatar.cc/150?img=12'),
      Conversation(id: 'mock-conversation-3', contactId: 'mock-contact-3', contactName: 'Mekdes Alemu', lastMessage: 'Can we review the product photos?', lastMessageAt: now.subtract(const Duration(hours: 5)), unreadCount: 1, isOnline: true, avatarUrl: 'https://i.pravatar.cc/150?img=32'),
      Conversation(id: 'mock-conversation-4', contactId: 'mock-contact-4', contactName: 'Solomon Girma', lastMessage: 'Great results from the weekend promotion.', lastMessageAt: now.subtract(const Duration(days: 1)), unreadCount: 0, isOnline: false, avatarUrl: 'https://i.pravatar.cc/150?img=68'),
      Conversation(id: 'mock-conversation-5', contactId: 'mock-contact-5', contactName: 'Bethelhem Kassa', lastMessage: 'I have sent the payout details.', lastMessageAt: now.subtract(const Duration(days: 2)), unreadCount: 3, isOnline: false, avatarUrl: 'https://i.pravatar.cc/150?img=45'),
      Conversation(id: 'mock-conversation-6', contactId: 'mock-contact-6', contactName: 'Yonas Mekonnen', lastMessage: 'Let us plan next week’s campaign.', lastMessageAt: now.subtract(const Duration(days: 4)), unreadCount: 0, isOnline: true, avatarUrl: 'https://i.pravatar.cc/150?img=13'),
    ];
  }

  static List<ChatMessage> messagesFor(String conversationId) {
    final now = DateTime.now();
    if (conversationId == 'mock-conversation-1') {
      return [
        ChatMessage(id: 'hana-12', content: 'Thank you, I will share the campaign link today.', sentAt: now.subtract(const Duration(minutes: 8)), isMine: false, status: 'read'),
        ChatMessage(id: 'hana-11', content: 'Perfect. Please tag the shop in the post.', sentAt: now.subtract(const Duration(minutes: 13)), isMine: true, status: 'read'),
        ChatMessage(id: 'hana-10', content: 'Should I use the new product photos?', sentAt: now.subtract(const Duration(minutes: 17)), isMine: false, status: 'read', imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=700&q=80'),
        ChatMessage(id: 'hana-9', content: 'Yes, those are the approved images.', sentAt: now.subtract(const Duration(minutes: 20)), isMine: true, status: 'read', imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=700&q=80'),
        ChatMessage(id: 'hana-8', content: 'I can start promoting the weekend offer tomorrow.', sentAt: now.subtract(const Duration(days: 1, hours: 2)), isMine: false, status: 'read'),
        ChatMessage(id: 'hana-7', content: 'That works well. The offer goes live at 9 AM.', sentAt: now.subtract(const Duration(days: 1, hours: 2, minutes: 3)), isMine: true, status: 'read'),
        ChatMessage(id: 'hana-6', content: 'I have reviewed the campaign brief.', sentAt: now.subtract(const Duration(days: 1, hours: 3)), isMine: false, status: 'read'),
        ChatMessage(id: 'hana-5', content: 'Hi Hana, I have sent the campaign brief.', sentAt: now.subtract(const Duration(days: 2, hours: 1)), isMine: true, status: 'delivered'),
        ChatMessage(id: 'hana-4', content: 'Thanks, I will look at it this evening.', sentAt: now.subtract(const Duration(days: 2, hours: 1, minutes: 5)), isMine: false, status: 'read'),
        ChatMessage(id: 'hana-3', content: 'Please let me know if you need anything else.', sentAt: now.subtract(const Duration(days: 2, hours: 1, minutes: 8)), isMine: true, status: 'sent'),
      ];
    }
    if (conversationId == 'mock-conversation-2') {
      return [
        ChatMessage(id: 'dawit-5', content: 'The new order is confirmed.', sentAt: now.subtract(const Duration(hours: 2)), isMine: false, status: 'read'),
        ChatMessage(id: 'dawit-4', content: 'Excellent, thank you for the update.', sentAt: now.subtract(const Duration(hours: 2, minutes: 4)), isMine: true, status: 'read'),
        ChatMessage(id: 'dawit-3', content: 'The customer completed payment this morning.', sentAt: now.subtract(const Duration(days: 1, hours: 1)), isMine: false, status: 'read', imageUrl: 'https://images.unsplash.com/photo-1556740749-887f6717d7e4?auto=format&fit=crop&w=700&q=80'),
        ChatMessage(id: 'dawit-2', content: 'I will watch for the order confirmation.', sentAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 3)), isMine: true, status: 'delivered'),
      ];
    }
    return [];
  }
}
