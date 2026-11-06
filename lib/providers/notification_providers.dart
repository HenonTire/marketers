import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/notification_models.dart';
import 'package:marketers/repositories/notification_repository.dart';
import 'package:marketers/providers/profile_providers.dart';

final notificationRepositoryProvider = Provider<BackendNotificationRepository>((ref) {
  return BackendNotificationRepository(ref.watch(apiClientProvider));
});

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.watch(notificationRepositoryProvider).fetchNotifications();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).fetchNotifications(),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).loadMore(current),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final beforeUpdate = state.valueOrNull;
    if (beforeUpdate == null) return;
    state = AsyncData([
      for (final notification in beforeUpdate)
        notification.id == notificationId
            ? notification.copyWith(isRead: true)
            : notification,
    ]);
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
    } catch (_) {
      state = AsyncData(beforeUpdate);
    }
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(NotificationsNotifier.new);
