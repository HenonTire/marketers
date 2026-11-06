import 'package:flutter/material.dart';
import 'package:marketers/config/mock_data_config.dart';
import 'package:marketers/mock_data/mock_notification_data.dart';
import 'package:marketers/models/notification_models.dart';
import 'package:marketers/service/api_client.dart';

class NotificationPageData {
  const NotificationPageData({required this.notifications, required this.nextPage});
  final List<AppNotification> notifications;
  final String? nextPage;
}

class BackendNotificationRepository {
  BackendNotificationRepository(this._client);

  final ApiClient _client;
  String? _nextPage;

  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final page = await fetchPage();
      _nextPage = page.nextPage;
      return page.notifications;
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('notifications', error);
      _nextPage = null;
      return MockNotificationData.notifications();
    }
  }

  Future<NotificationPageData> fetchPage({String? nextPage}) async {
    final response = nextPage == null
        ? await _client.get('/api/notifications/', queryParameters: const {'page_size': 100})
        : await _client.get(nextPage);
    final body = _asMap(response.data);
    final rawItems = body['results'] ?? body['notifications'] ?? const [];
    if (rawItems is! List) throw const ApiFailure(ApiFailureKind.response, 'The notifications response was invalid.');
    return NotificationPageData(
      notifications: rawItems.whereType<Map>().map((item) => _fromJson(Map<String, dynamic>.from(item))).toList(),
      nextPage: body['next']?.toString(),
    );
  }

  bool get hasNextPage => _nextPage != null && _nextPage!.isNotEmpty;

  Future<List<AppNotification>> loadMore(List<AppNotification> current) async {
    if (!hasNextPage) return current;
    final page = await fetchPage(nextPage: _nextPage);
    _nextPage = page.nextPage;
    return [...current, ...page.notifications];
  }

  Future<void> markAsRead(String notificationId) async {
    if (notificationId.startsWith('mock-')) return;
    try {
      await _client.patch('/api/notifications/$notificationId/read/');
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('notification mark read', error);
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : throw const ApiFailure(ApiFailureKind.response, 'The notifications response was invalid.');

  static AppNotification _fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    message: json['message']?.toString() ?? '',
    timestamp: json['created_at']?.toString() ?? '',
    isRead: json['is_read'] == true,
    icon: _iconForType(json['type']?.toString() ?? ''),
  );

  /// Every value declared by notifications.Notification.Type is mapped here.
  static IconData _iconForType(String type) {
    switch (type) {
      case 'payment_success': case 'payment_confirmed': case 'refund_completed': case 'commission_created': case 'commission_approved': return Icons.monetization_on;
      case 'order_shipped': case 'order_delivered': return Icons.local_shipping_outlined;
      case 'order_cancelled': return Icons.cancel_outlined;
      case 'low_stock_alert': return Icons.inventory_2_outlined;
      case 'new_order': case 'product_sold': return Icons.store_outlined;
      default: return Icons.notifications_outlined;
    }
  }
}
