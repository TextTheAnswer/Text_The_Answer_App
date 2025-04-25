import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:text_the_answer/utils/theme.dart';

enum AppThemeMode { defaultTheme, light, dark }

class ThemeState extends Equatable {
  final ThemeData themeData;
  final AppThemeMode mode;

  const ThemeState({required this.themeData, required this.mode});

  @override
  List<Object?> get props => [mode];
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _storage = FlutterSecureStorage();
  static const _themeKey = 'selected_theme';

  ThemeCubit() : super(_defaultTheme) {
    _loadThemeFromPrefs();
  }

  static final ThemeState _defaultTheme = ThemeState(
    themeData: AppTheme.defaultTheme(),
    mode: AppThemeMode.defaultTheme,
  );

  static final ThemeState _lightTheme = ThemeState(
    themeData: ThemeData.light(useMaterial3: true),
    mode: AppThemeMode.light,
  );

  static final ThemeState _darkTheme = ThemeState(
    themeData: ThemeData.dark(useMaterial3: true),
    mode: AppThemeMode.dark,
  );

  Future<void> _loadThemeFromPrefs() async {
    final index = int.tryParse(await _storage.read(key: _themeKey) ?? '0') ?? 0;
    setTheme(AppThemeMode.values[index]);
  }

  Future<void> setTheme(AppThemeMode mode) async {
    late ThemeState newState;
    switch (mode) {
      case AppThemeMode.light:
        newState = _lightTheme;
        break;
      case AppThemeMode.dark:
        newState = _darkTheme;
        break;
      case AppThemeMode.defaultTheme:
        newState = _defaultTheme;
        break;
    }

    emit(newState);
    await _storage.write(key: _themeKey, value: mode.index.toString());
  }
}
