import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/widgets/app_drawer.dart';

/// Common UI utilities for maintaining consistent UI across the app
class CommonUI {
  /// Creates a standard app bar with customizable title and actions
  static AppBar buildAppBar({
    required BuildContext context,
    required String title,
    required bool isDarkMode,
    required VoidCallback toggleTheme,
    List<Widget>? additionalActions,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: toggleTheme,
        ),
        ...?additionalActions,
      ],
    );
  }

  /// Creates a consistent drawer for all screens
  static Widget buildDrawer({
    required BuildContext context, 
    required VoidCallback toggleTheme, 
    required bool isDarkMode,
  }) {
    return AppDrawer(
      toggleTheme: toggleTheme,
      isDarkMode: isDarkMode,
    );
  }
} 