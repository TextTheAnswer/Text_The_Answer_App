import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/category/category_event.dart';
import 'package:text_the_answer/blocs/category/category_state.dart';
import 'package:text_the_answer/models/category.dart';
import 'package:text_the_answer/models/theme.dart';
import 'package:text_the_answer/services/api_service.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final ApiService apiService;
  
  CategoryBloc({required this.apiService}) : super(CategoryInitial()) {
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<FetchCategoryByIdEvent>(_onFetchCategoryById);
    on<FetchCurrentThemeEvent>(_onFetchCurrentTheme);
    on<FetchUpcomingThemesEvent>(_onFetchUpcomingThemes);
  }

  FutureOr<void> _onFetchCategories(
    FetchCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await apiService.getCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  FutureOr<void> _onFetchCategoryById(
    FetchCategoryByIdEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final category = await apiService.getCategoryById(event.categoryId);
      emit(CategoryLoaded(category));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  FutureOr<void> _onFetchCurrentTheme(
    FetchCurrentThemeEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(ThemeLoading());
    try {
      final theme = await apiService.getCurrentTheme();
      emit(CurrentThemeLoaded(
        themeName: theme.name,
        themeDescription: theme.description,
      ));
    } catch (e) {
      emit(ThemeError(e.toString()));
    }
  }

  FutureOr<void> _onFetchUpcomingThemes(
    FetchUpcomingThemesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(ThemeLoading());
    try {
      final themes = await apiService.getUpcomingThemes();
      final themesList = themes.map((theme) => {
        'id': theme.id,
        'name': theme.name,
        'description': theme.description,
        'categoryName': theme.categoryName,
        'date': theme.date,
      }).toList();
      emit(UpcomingThemesLoaded(themesList));
    } catch (e) {
      emit(ThemeError(e.toString()));
    }
  }
}
