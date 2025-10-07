import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class EmptyState extends StatelessWidget {
  final AppTheme appTheme;

  const EmptyState({
    super.key,
    required this.appTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 80,
            color: appTheme.textSecondaryColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No items yet',
            style: TextStyle(
              fontSize: 18,
              color: appTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first item',
            style: TextStyle(
              fontSize: 14,
              color: appTheme.textSecondaryColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
