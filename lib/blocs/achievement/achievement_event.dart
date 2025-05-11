import 'package:equatable/equatable.dart';
import '../../models/achievement.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllAchievements extends AchievementEvent {}

class LoadUserAchievements extends AchievementEvent {}

class LoadAchievementProgress extends AchievementEvent {}

class LoadHiddenAchievements extends AchievementEvent {}

class MarkAchievementAsViewed extends AchievementEvent {
  final String achievementId;

  const MarkAchievementAsViewed(this.achievementId);

  @override
  List<Object?> get props => [achievementId];
}

class UnlockAchievement extends AchievementEvent {
  final Achievement achievement;

  const UnlockAchievement(this.achievement);

  @override
  List<Object?> get props => [achievement];
} 