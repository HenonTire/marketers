import 'package:flutter/material.dart';

class Shop {
  const Shop({
    required this.id,
    required this.name,
    required this.badge,
    required this.description,
    required this.imageUrl,
    required this.ordersCount,
    required this.domain,
    required this.createdAt,
    required this.theme,
    required this.themeSettings,
    required this.rating,
    required this.category,
    required this.isOnline,
    required this.isOpen,
    required this.products,
  });

  final String id;
  final String name;
  final String badge;
  final String description;
  final String imageUrl;
  final int ordersCount;
  final String domain;
  final DateTime? createdAt;
  final String? theme;
  final ShopTheme themeSettings;
  final double rating;
  final String? category;
  final bool isOnline;
  final bool isOpen;
  final List<ShopProduct> products;
}

class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String? category;
  final String? imageUrl;
}

class ShopTheme {
  static const defaultPrimaryColor = Color(0xFF4CAF50);
  static const defaultSecondaryColor = Color(0xFFFFFFFF);

  final Color primaryColor;
  final Color secondaryColor;
  final String? logo;
  final String? bannerImage;
  final String? fontFamily;

  const ShopTheme({
    this.primaryColor = defaultPrimaryColor,
    this.secondaryColor = defaultSecondaryColor,
    this.logo,
    this.bannerImage,
    this.fontFamily,
  });
}
