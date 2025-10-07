import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppTheme appTheme;
  final String userName;
  final Widget? filterMenu;
  final VoidCallback? onThemeToggle;

  const GradientAppBar({
    super.key,
    required this.title,
    required this.appTheme,
    required this.userName,
    this.filterMenu,
    this.onThemeToggle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: appTheme.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      foregroundColor: Colors.white,
      actions: [
        if (filterMenu != null) filterMenu!,
        // Theme toggle button
        IconButton(
          icon: Icon(appTheme.isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: onThemeToggle,
          tooltip: appTheme.isDark ? 'Light Mode' : 'Dark Mode',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
