import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/chat_models.dart';
import 'package:marketers/providers/chat_providers.dart';
import 'package:marketers/service/app_themes.dart';
import 'package:marketers/service/colors.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  const ChatDetailPage({super.key, required this.conversation});
  final Conversation conversation;

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _poller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _hasText = _controller.text.trim().isNotEmpty));
    _scrollController.addListener(() { if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) ref.read(messagesProvider(widget.conversation.id).notifier).loadOlder(); });
    _poller = Timer.periodic(const Duration(seconds: 12), (_) => ref.read(messagesProvider(widget.conversation.id).notifier).refresh());
    Future.microtask(() => ref.read(chatRepositoryProvider).markAsRead(widget.conversation.id));
  }

  @override
  void dispose() { _poller?.cancel(); _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.conversation.id));
    ref.listen(messagesProvider(widget.conversation.id), (_, next) { if (next.hasValue) _scrollToBottom(); });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, color: AppColors.silverMist)), title: _title()),
      body: Column(children: [
        Expanded(child: messages.when(loading: _loading, error: (e, _) => Center(child: Text('Could not load messages', style: AppThemes.poppins(context, color: AppColors.ivory))), data: _thread)),
        _composer(),
      ]),
    );
  }

  Widget _title() => Row(children: [CircleAvatar(radius: 18, backgroundColor: AppColors.surface, backgroundImage: widget.conversation.avatarUrl?.isNotEmpty == true ? NetworkImage(widget.conversation.avatarUrl!) : null, child: widget.conversation.avatarUrl?.isNotEmpty == true ? null : Icon(Icons.person, color: AppColors.ivory, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.conversation.contactName, style: AppThemes.poppins(context, fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ivory)), Text(widget.conversation.isOnline ? 'Online' : 'Offline', style: AppThemes.poppins(context, fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(.60)))]))]);

  Widget _thread(List<ChatMessage> messages) {
    if (messages.isEmpty) return Center(child: Text('No messages yet', style: AppThemes.poppins(context, color: AppColors.textDisabled)));
    return ListView.builder(
      controller: _scrollController, reverse: true, padding: const EdgeInsets.fromLTRB(12, 12, 12, 8), itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showDate = index == messages.length - 1 || !_sameDay(message.sentAt, messages[index + 1].sentAt);
        return Column(children: [if (showDate) _dateSeparator(message.sentAt), _message(message)]);
      },
    );
  }

  Widget _dateSeparator(DateTime date) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('${date.day}/${date.month}/${date.year}', style: AppThemes.poppins(context, fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(.60))));
  bool _sameDay(DateTime first, DateTime second) => first.year == second.year && first.month == second.month && first.day == second.day;

  Widget _message(ChatMessage message) {
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(.60);
    return Align(alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft, child: Container(
      constraints: const BoxConstraints(maxWidth: 280), margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: message.isMine ? AppColors.elevatedSurface : AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (message.imageUrl?.isNotEmpty == true) ...[
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(message.imageUrl!, width: 220, height: 150, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 220, height: 150, color: AppColors.background, child: Icon(Icons.broken_image_outlined, color: AppColors.textDisabled)))),
          if (message.content.isNotEmpty) const SizedBox(height: 8),
        ],
        if (message.content.isNotEmpty) Text(message.content, style: AppThemes.poppins(context, fontSize: 13, color: AppColors.ivory)),
        const SizedBox(height: 3),
        Row(mainAxisSize: MainAxisSize.min, children: [Text('${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}', style: AppThemes.poppins(context, fontSize: 9, color: muted)), if (message.isMine) ...[const SizedBox(width: 4), Icon(message.status == 'read' ? Icons.done_all : Icons.done, size: 13, color: muted)]])
      ]),
    ));
  }

  Widget _composer() => SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(10, 8, 10, 12), color: AppColors.background, child: Row(children: [
    IconButton(onPressed: null, icon: Icon(Icons.image_outlined, color: AppColors.textDisabled)),
    Expanded(child: Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(30)), child: TextField(controller: _controller, minLines: 1, maxLines: 4, style: AppThemes.poppins(context, fontSize: 14, color: AppColors.ivory), decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), hintText: 'Type a message', hintStyle: AppThemes.poppins(context, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(.60)))))),
    IconButton(onPressed: _hasText ? _send : null, icon: Icon(Icons.send_rounded, color: _hasText ? AppColors.silverMist : AppColors.textDisabled)),
  ])));

  Widget _loading() => ListView.builder(reverse: true, itemCount: 8, itemBuilder: (_, __) => Align(alignment: Alignment.centerLeft, child: Container(width: 160, height: 46, margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)))));
  Future<void> _send() async { final content = _controller.text.trim(); if (content.isEmpty) return; _controller.clear(); await ref.read(messagesProvider(widget.conversation.id).notifier).send(content); _scrollToBottom(); }
  void _scrollToBottom() { if (_scrollController.hasClients) _scrollController.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOut); }
}
