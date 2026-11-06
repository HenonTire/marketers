import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/notification_models.dart';
import 'package:marketers/pages/message.dart';
import 'package:marketers/providers/notification_providers.dart';
import 'package:marketers/service/colors.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: notificationsAsync.when(
          loading: _loadingUI,
          error: (e, _) => Center(child: Text('Error loading notifications', style: TextStyle(color: AppColors.ivory))),
          data: _buildUI,
        ),
      )),
    );
  }

  Widget _loadingUI() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 20), _topBar(), const SizedBox(height: 20), _sectionHeader(),
    Expanded(child: ListView.builder(itemCount: 5, itemBuilder: (_, __) => _notificationSkeleton())),
  ]);

  Widget _buildUI(List<AppNotification> notifications) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 20), _topBar(), const SizedBox(height: 20), _sectionHeader(),
    Expanded(child: notifications.isEmpty ? _emptyState() : ListView.builder(
      padding: const EdgeInsets.only(bottom: 100), itemCount: notifications.length,
      itemBuilder: (context, index) => _notificationCard(notifications[index]),
    )),
  ]);

  Widget _topBar() => const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 18));
  Widget _sectionHeader() => Divider(color: AppColors.divider, thickness: 1, indent: 8, endIndent: 8, height: 30);

  Widget _emptyState() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 48),
    const SizedBox(height: 12),
    const Text('No notifications yet', style: TextStyle(color: Colors.white38, fontSize: 14)),
  ]));

  Widget _notificationCard(AppNotification notification) => GestureDetector(
    onTap: () {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
      if (notification.opensMessages) Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagePage()));
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: notification.isRead ? AppColors.surface : AppColors.elevatedSurface, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(notification.icon, color: AppColors.silverMist, size: 22), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notification.title, style: TextStyle(color: Colors.white, fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
          const SizedBox(height: 4), Text(notification.message, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 6), Text(notification.timestamp, style: TextStyle(color: AppColors.textDisabled, fontSize: 10)),
        ])),
        if (!notification.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.ivory, shape: BoxShape.circle)),
      ]),
    ),
  );

  Widget _notificationSkeleton() => Container(
    height: 88, margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
    child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
      Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle)), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 120, height: 12, color: Colors.white10), const SizedBox(height: 8), Container(width: double.infinity, height: 10, color: Colors.white10),
      ])),
    ])),
  );
}
