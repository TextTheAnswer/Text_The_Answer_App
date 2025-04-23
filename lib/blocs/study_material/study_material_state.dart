import 'package:equatable/equatable.dart';
import 'package:text_the_answer/models/study_material.dart';

abstract class StudyMaterialState extends Equatable {
  const StudyMaterialState();
  
  @override
  List<Object> get props => [];
}

class StudyMaterialInitial extends StudyMaterialState {}

class StudyMaterialLoading extends StudyMaterialState {}

class StudyMaterialsLoaded extends StudyMaterialState {
  final List<StudyMaterial> materials;
  
  const StudyMaterialsLoaded(this.materials);
  
  @override
  List<Object> get props => [materials];
}

class StudyMaterialCreated extends StudyMaterialState {
  final StudyMaterial material;
  
  const StudyMaterialCreated(this.material);
  
  @override
  List<Object> get props => [material];
}

class StudyMaterialUpdated extends StudyMaterialState {
  final StudyMaterial material;
  
  const StudyMaterialUpdated(this.material);
  
  @override
  List<Object> get props => [material];
}

class StudyMaterialDeleted extends StudyMaterialState {
  final String id;
  
  const StudyMaterialDeleted(this.id);
  
  @override
  List<Object> get props => [id];
}

class QuestionsGenerated extends StudyMaterialState {
  final List<Map<String, dynamic>> questions;
  
  const QuestionsGenerated(this.questions);
  
  @override
  List<Object> get props => [questions];
}

class StudyMaterialError extends StudyMaterialState {
  final String message;
  
  const StudyMaterialError(this.message);
  
  @override
  List<Object> get props => [message];
}
