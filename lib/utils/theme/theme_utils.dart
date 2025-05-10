import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_cubit.dart';

/// A utility class for handling theme toggling consistently across the app
class ThemeUtils {
  /// Toggle between light and dark theme modes
  static VoidCallback getThemeToggler(BuildContext context, [VoidCallback? callback]) {
    return () {
      // Get the current ThemeCubit and its state
      final ThemeCubit cubit = context.read<ThemeCubit>();
      final currentState = cubit.state;
      
      // Toggle between light and dark modes
      if (currentState.mode == AppThemeMode.dark) {
        cubit.setTheme(AppThemeMode.light);
      } else {
        cubit.setTheme(AppThemeMode.dark);
      }
      
      // Call the optional callback if provided
      if (callback != null) {
        callback();
      }
    };
  }
  
  /// Get a builder widget that rebuilds when theme changes
  static Widget withThemeListener({
    required BuildContext context,
    required Widget Function(BuildContext, ThemeState) builder,
  }) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: builder,
    );
  }
} 