import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  
  @override
  List<Object> get props => [];
}

class FetchCategoriesEvent extends CategoryEvent {}

class FetchCategoryByIdEvent extends CategoryEvent {
  final String categoryId;
  
  const FetchCategoryByIdEvent(this.categoryId);
  
  @override
  List<Object> get props => [categoryId];
}

class FetchCurrentThemeEvent extends CategoryEvent {}

class FetchUpcomingThemesEvent extends CategoryEvent {}
