import 'package:flutter/material.dart';
import 'package:marketers/models/shop_models.dart';
import 'package:marketers/pages/shop_detail_page.dart';
import 'package:marketers/service/colors.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final double width;

  const ShopCard({super.key, required this.shop, this.width = 150});

  String _compact(int n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    }
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return '$n';
  }

  String get _imageUrl {
    final main = shop.imageUrl.trim();
    if (main.isNotEmpty) return main;
    return shop.themeSettings.logo?.trim() ?? '';
  }

  String get _ratingText {
    if (shop.rating > 0) return shop.rating.toStringAsFixed(1);
    return shop.badge.trim();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    return Container(
      width: width,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShopDetailPage(shopId: shop.id),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildImage()),
                _buildInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── IMAGE AREA ───────────────────────────

  Widget _buildImage() {
    final category = shop.category?.trim() ?? '';
    final rating = _ratingText;

    return Stack(
      fit: StackFit.expand,
      children: [
        _image(),

        // Bottom fade so overlay chips stay readable on any photo.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.45, 1],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),

        // Open / closed
        Positioned(
          top: 8,
          left: 8,
          child: _chip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: shop.isOpen ? Colors.greenAccent : Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  shop.isOpen ? 'Open' : 'Closed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Rating
        if (rating.isNotEmpty)
          Positioned(
            top: 8,
            right: 8,
            child: _chip(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                  const SizedBox(width: 3),
                  Text(
                    rating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Category
        if (category.isNotEmpty)
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.pearl.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _image() {
    final url = _imageUrl;
    if (url.isEmpty) return _placeholder();

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(loading: true);
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) {
    final color = shop.themeSettings.primaryColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.35), AppColors.elevatedSurface],
        ),
      ),
      child: Center(
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textDisabled,
                ),
              )
            : Icon(
                Icons.storefront_rounded,
                size: 34,
                color: AppColors.textPrimary.withValues(alpha: 0.55),
              ),
      ),
    );
  }

  Widget _chip({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  // ─────────────────────────── INFO AREA ───────────────────────────

  Widget _buildInfo() {
    final description = shop.description.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description.isEmpty ? 'No description yet' : description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textDisabled, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 13,
                color: AppColors.textDisabled,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_compact(shop.ordersCount)} orders',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.pearl.withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.arrow_outward_rounded,
                  size: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
