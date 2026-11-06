import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final bool isRead;
  final IconData icon;
  final bool opensMessages;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.icon,
    this.opensMessages = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        message: message,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        icon: icon,
        opensMessages: opensMessages,
      );
}
