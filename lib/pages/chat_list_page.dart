import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/chat_models.dart';
import 'package:marketers/pages/chat_detail_page.dart';
import 'package:marketers/providers/chat_providers.dart';
import 'package:marketers/service/app_themes.dart';
import 'package:marketers/service/colors.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    _poller = Timer.periodic(const Duration(seconds: 20), (_) => ref.read(conversationsProvider.notifier).refresh());
  }

  @override
  void dispose() { _poller?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(filteredConversationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Text('Messages', style: AppThemes.poppins(context, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ivory)),
          const SizedBox(height: 14),
          _searchBar(),
          const SizedBox(height: 12),
          Expanded(child: conversations.when(
            loading: _loadingUI,
            error: (error, _) => Center(child: Text('Could not load conversations', style: AppThemes.poppins(context, color: AppColors.ivory))),
            data: _buildList,
          )),
        ]),
      )),
    );
  }

  Widget _searchBar() => Container(
    height: 45, padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(40)),
    child: TextField(
      onChanged: (value) => ref.read(chatSearchQueryProvider.notifier).state = value,
      style: AppThemes.poppins(context, fontSize: 14, color: AppColors.ivory),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: AppColors.textDisabled),
        hintText: 'Search messages...',
        hintStyle: AppThemes.poppins(context, fontSize: 13, color: AppColors.textDisabled),
      ),
    ),
  );

  Widget _buildList(List<Conversation> conversations) {
    if (conversations.isEmpty) return _emptyState();
    return RefreshIndicator(
      onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100), itemCount: conversations.length,
        itemBuilder: (context, index) => _conversationTile(conversations[index]),
      ),
    );
  }

  Widget _conversationTile(Conversation conversation) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailPage(conversation: conversation))),
      leading: _avatar(conversation),
      title: Text(
        conversation.contactName,
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: AppThemes.poppins(context, fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ivory),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: AppThemes.poppins(context, fontSize: 12, color: AppColors.textDisabled),
      ),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(_timeLabel(conversation.lastMessageAt), style: AppThemes.poppins(context, fontSize: 10, color: AppColors.textDisabled)),
        const SizedBox(height: 6),
        if (conversation.unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.elevatedSurface, borderRadius: BorderRadius.circular(12)),
            child: Text('${conversation.unreadCount}', style: AppThemes.poppins(context, fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.ivory)),
          ),
      ]),
    );
  }

  Widget _avatar(Conversation conversation) {
    final hasAvatar = conversation.avatarUrl?.isNotEmpty == true;
    return Stack(clipBehavior: Clip.none, children: [
      CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.surface,
        backgroundImage: hasAvatar ? NetworkImage(conversation.avatarUrl!) : null,
        onBackgroundImageError: hasAvatar ? (_, __) {} : null,
        child: hasAvatar ? null : Icon(Icons.person, color: AppColors.ivory, size: 26),
      ),
      Positioned(
        right: -1, bottom: -1,
        child: Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: conversation.isOnline ? AppColors.success : AppColors.textDisabled,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: 2),
          ),
        ),
      ),
    ]);
  }

  Widget _emptyState() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textDisabled, size: 48), const SizedBox(height: 12), Text('No conversations yet', style: AppThemes.poppins(context, fontSize: 14, color: AppColors.textDisabled))]));
  Widget _loadingUI() => ListView.builder(itemCount: 6, itemBuilder: (_, __) => Container(height: 66, margin: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16))));
  String _timeLabel(DateTime? value) => value == null ? '' : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}