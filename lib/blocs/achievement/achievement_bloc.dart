import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/achievement.dart';
import '../../services/achievement_service.dart';
import 'achievement_event.dart';
import 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final AchievementService _achievementService;

  AchievementBloc({required AchievementService achievementService})
      : _achievementService = achievementService,
        super(AchievementInitial()) {
    on<LoadAllAchievements>(_onLoadAllAchievements);
    on<LoadUserAchievements>(_onLoadUserAchievements);
    on<LoadAchievementProgress>(_onLoadAchievementProgress);
    on<LoadHiddenAchievements>(_onLoadHiddenAchievements);
    on<MarkAchievementAsViewed>(_onMarkAchievementAsViewed);
    on<UnlockAchievement>(_onUnlockAchievement);
  }

  Future<void> _onLoadAllAchievements(
    LoadAllAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementLoading());
    try {
      final achievements = await _achievementService.getAllAchievements();
      emit(AllAchievementsLoaded(achievements));
    } catch (e) {
      emit(AchievementError('Failed to load achievements: $e'));
    }
  }

  Future<void> _onLoadUserAchievements(
    LoadUserAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementLoading());
    try {
      final achievements = await _achievementService.getUserAchievements();
      // Filter unviewed achievements
      final unviewedAchievements = achievements.where((a) => !a.viewed).toList();
      emit(UserAchievementsLoaded(
        achievements: achievements,
        unviewedAchievements: unviewedAchievements,
      ));
    } catch (e) {
      emit(AchievementError('Failed to load user achievements: $e'));
    }
  }

  Future<void> _onLoadAchievementProgress(
    LoadAchievementProgress event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementLoading());
    try {
      final progress = await _achievementService.getAchievementProgress();
      emit(AchievementProgressLoaded(progress));
    } catch (e) {
      emit(AchievementError('Failed to load achievement progress: $e'));
    }
  }

  Future<void> _onLoadHiddenAchievements(
    LoadHiddenAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementLoading());
    try {
      final hiddenAchievements = await _achievementService.getHiddenAchievements();
      emit(HiddenAchievementsLoaded(hiddenAchievements));
    } catch (e) {
      emit(AchievementError('Failed to load hidden achievements: $e'));
    }
  }

  Future<void> _onMarkAchievementAsViewed(
    MarkAchievementAsViewed event,
    Emitter<AchievementState> emit,
  ) async {
    try {
      final success = await _achievementService.markAchievementAsViewed(
        event.achievementId,
      );
      if (success) {
        emit(AchievementMarkedAsViewed(event.achievementId));
        // Reload user achievements to get updated list
        add(LoadUserAchievements());
      }
    } catch (e) {
      emit(AchievementError('Failed to mark achievement as viewed: $e'));
    }
  }

  Future<void> _onUnlockAchievement(
    UnlockAchievement event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementUnlocked(event.achievement));
    // Reload user achievements to get updated list
    add(LoadUserAchievements());
  }
} 