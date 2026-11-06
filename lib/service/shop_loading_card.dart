import 'package:flutter/material.dart';
import 'package:marketers/service/colors.dart';

class ShopSkeletonCard extends StatelessWidget {
  const ShopSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      width: 150,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20, width: 60, color: Colors.white10),
            const SizedBox(height: 10),
            Container(height: 12, width: 100, color: Colors.white10),
            const Spacer(),
            Container(height: 12, width: 40, color: Colors.white10),
          ],
        ),
      ),
    );
  }
}