import 'package:equatable/equatable.dart';

abstract class StudyMaterialEvent extends Equatable {
  const StudyMaterialEvent();
  
  @override
  List<Object> get props => [];
}

class FetchStudyMaterialsEvent extends StudyMaterialEvent {}

class CreateStudyMaterialEvent extends StudyMaterialEvent {
  final String title;
  final String content;
  final List<String> tags;
  
  const CreateStudyMaterialEvent({
    required this.title,
    required this.content,
    required this.tags,
  });
  
  @override
  List<Object> get props => [title, content, tags];
}

class UpdateStudyMaterialEvent extends StudyMaterialEvent {
  final String id;
  final Map<String, dynamic> updates;
  
  const UpdateStudyMaterialEvent({
    required this.id,
    required this.updates,
  });
  
  @override
  List<Object> get props => [id, updates];
}

class DeleteStudyMaterialEvent extends StudyMaterialEvent {
  final String id;
  
  const DeleteStudyMaterialEvent(this.id);
  
  @override
  List<Object> get props => [id];
}

class GenerateQuestionsEvent extends StudyMaterialEvent {
  final String materialId;
  
  const GenerateQuestionsEvent(this.materialId);
  
  @override
  List<Object> get props => [materialId];
}
