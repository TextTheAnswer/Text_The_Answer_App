import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/theme/theme_cubit.dart';

/// A wrapper widget for components that need to be theme-aware.
/// This ensures proper rebuilding when the theme changes.
class ThemeAwareWidget extends StatelessWidget {
  final Widget Function(BuildContext, ThemeState) builder;
  
  const ThemeAwareWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) => previous.mode != current.mode,
      builder: builder,
    );
  }
}

/// Extension method for BuildContext to easily get the current theme state
extension ThemeContextExtension on BuildContext {
  ThemeState get themeState => read<ThemeCubit>().state;
  
  /// Toggle the theme mode between light and dark
  void toggleTheme([VoidCallback? callback]) {
    final cubit = read<ThemeCubit>();
    final currentState = cubit.state;
    
    if (currentState.mode == AppThemeMode.dark) {
      cubit.setTheme(AppThemeMode.light);
    } else {
      cubit.setTheme(AppThemeMode.dark);
    }
    
    if (callback != null) {
      callback();
    }
  }
} 