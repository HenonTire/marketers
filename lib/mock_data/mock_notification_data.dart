import 'package:flutter/material.dart';
import 'package:marketers/models/notification_models.dart';

class MockNotificationData {
  MockNotificationData._();

  static List<AppNotification> notifications() {
    return const [
      AppNotification(id: 'mock-notification-1', title: 'New order', message: 'A new order was placed through your campaign.', timestamp: '8 min ago', isRead: false, icon: Icons.store_outlined),
      AppNotification(id: 'mock-notification-2', title: 'Payment confirmed', message: 'Payment for order #SK-1042 has been confirmed.', timestamp: '45 min ago', isRead: false, icon: Icons.monetization_on),
      AppNotification(id: 'mock-notification-3', title: 'Low stock alert', message: 'A promoted product is running low on stock.', timestamp: '2 hours ago', isRead: false, icon: Icons.inventory_2_outlined),
      AppNotification(id: 'mock-notification-4', title: 'Commission approved', message: 'Your commission for a delivered order is approved.', timestamp: 'Yesterday', isRead: true, icon: Icons.monetization_on),
      AppNotification(id: 'mock-notification-5', title: 'Order shipped', message: 'An order from your campaign is now on its way.', timestamp: 'Yesterday', isRead: true, icon: Icons.local_shipping_outlined),
      AppNotification(id: 'mock-notification-6', title: 'Supplier update', message: 'A supplier updated availability for a promoted product.', timestamp: '2 days ago', isRead: true, icon: Icons.inventory_2_outlined),
      AppNotification(id: 'mock-notification-7', title: 'Refund completed', message: 'A customer refund has been completed.', timestamp: '3 days ago', isRead: true, icon: Icons.monetization_on),
      AppNotification(id: 'mock-notification-8', title: 'System announcement', message: 'New marketing tools are now available in Shikela.', timestamp: '4 days ago', isRead: true, icon: Icons.notifications_outlined),
      AppNotification(id: 'mock-notification-9', title: 'Order delivered', message: 'A customer has received an order from your campaign.', timestamp: '5 days ago', isRead: true, icon: Icons.local_shipping_outlined),
    ];
  }
}
