import 'package:equatable/equatable.dart';
import 'package:text_the_answer/models/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  
  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<Category> categories;
  
  const CategoriesLoaded(this.categories);
  
  @override
  List<Object> get props => [categories];
}

class CategoryLoaded extends CategoryState {
  final Category category;
  
  const CategoryLoaded(this.category);
  
  @override
  List<Object> get props => [category];
}

class CategoryError extends CategoryState {
  final String message;
  
  const CategoryError(this.message);
  
  @override
  List<Object> get props => [message];
}

class ThemeLoading extends CategoryState {}

class CurrentThemeLoaded extends CategoryState {
  final String themeName;
  final String themeDescription;
  
  const CurrentThemeLoaded({
    required this.themeName,
    required this.themeDescription,
  });
  
  @override
  List<Object> get props => [themeName, themeDescription];
}

class UpcomingThemesLoaded extends CategoryState {
  final List<Map<String, dynamic>> themes;
  
  const UpcomingThemesLoaded(this.themes);
  
  @override
  List<Object> get props => [themes];
}

class ThemeError extends CategoryState {
  final String message;
  
  const ThemeError(this.message);
  
  @override
  List<Object> get props => [message];
}
