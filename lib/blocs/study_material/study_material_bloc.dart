import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/study_material/study_material_event.dart';
import 'package:text_the_answer/blocs/study_material/study_material_state.dart';
import 'package:text_the_answer/services/api_service.dart';

class StudyMaterialBloc extends Bloc<StudyMaterialEvent, StudyMaterialState> {
  final ApiService apiService;
  
  StudyMaterialBloc({required this.apiService}) : super(StudyMaterialInitial()) {
    on<FetchStudyMaterialsEvent>(_onFetchStudyMaterials);
    on<CreateStudyMaterialEvent>(_onCreateStudyMaterial);
    on<UpdateStudyMaterialEvent>(_onUpdateStudyMaterial);
    on<DeleteStudyMaterialEvent>(_onDeleteStudyMaterial);
    on<GenerateQuestionsEvent>(_onGenerateQuestions);
  }

  FutureOr<void> _onFetchStudyMaterials(
    FetchStudyMaterialsEvent event,
    Emitter<StudyMaterialState> emit,
  ) async {
    emit(StudyMaterialLoading());
    try {
      final materials = await apiService.getStudyMaterials();
      emit(StudyMaterialsLoaded(materials));
    } catch (e) {
      emit(StudyMaterialError(e.toString()));
    }
  }

  FutureOr<void> _onCreateStudyMaterial(
    CreateStudyMaterialEvent event,
    Emitter<StudyMaterialState> emit,
  ) async {
    emit(StudyMaterialLoading());
    try {
      final material = await apiService.createStudyMaterial(
        event.title,
        event.content,
        event.tags,
      );
      emit(StudyMaterialCreated(material));
    } catch (e) {
      emit(StudyMaterialError(e.toString()));
    }
  }

  FutureOr<void> _onUpdateStudyMaterial(
    UpdateStudyMaterialEvent event,
    Emitter<StudyMaterialState> emit,
  ) async {
    emit(StudyMaterialLoading());
    try {
      final material = await apiService.updateStudyMaterial(
        event.id,
        event.updates,
      );
      emit(StudyMaterialUpdated(material));
    } catch (e) {
      emit(StudyMaterialError(e.toString()));
    }
  }

  FutureOr<void> _onDeleteStudyMaterial(
    DeleteStudyMaterialEvent event,
    Emitter<StudyMaterialState> emit,
  ) async {
    emit(StudyMaterialLoading());
    try {
      await apiService.deleteStudyMaterial(event.id);
      emit(StudyMaterialDeleted(event.id));
    } catch (e) {
      emit(StudyMaterialError(e.toString()));
    }
  }

  FutureOr<void> _onGenerateQuestions(
    GenerateQuestionsEvent event,
    Emitter<StudyMaterialState> emit,
  ) async {
    emit(StudyMaterialLoading());
    try {
      final result = await apiService.generateQuestionsFromMaterial(event.materialId);
      final questions = List<Map<String, dynamic>>.from(result['questions'] ?? []);
      emit(QuestionsGenerated(questions));
    } catch (e) {
      emit(StudyMaterialError(e.toString()));
    }
  }
}
