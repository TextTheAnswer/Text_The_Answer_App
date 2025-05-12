import 'package:equatable/equatable.dart';
import '../../models/achievement.dart';

abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object?> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementLoading extends AchievementState {}

class AchievementError extends AchievementState {
  final String message;

  const AchievementError(this.message);

  @override
  List<Object?> get props => [message];
}

class AllAchievementsLoaded extends AchievementState {
  final List<Achievement> achievements;

  const AllAchievementsLoaded(this.achievements);

  @override
  List<Object?> get props => [achievements];
}

class UserAchievementsLoaded extends AchievementState {
  final List<Achievement> achievements;
  final List<Achievement> unviewedAchievements;

  const UserAchievementsLoaded({
    required this.achievements, 
    this.unviewedAchievements = const [],
  });

  @override
  List<Object?> get props => [achievements, unviewedAchievements];
}

class HiddenAchievementsLoaded extends AchievementState {
  final List<Achievement> hiddenAchievements;

  const HiddenAchievementsLoaded(this.hiddenAchievements);

  @override
  List<Object?> get props => [hiddenAchievements];
}

class AchievementProgressLoaded extends AchievementState {
  final Map<String, dynamic> progress;

  const AchievementProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

class AchievementMarkedAsViewed extends AchievementState {
  final String achievementId;

  const AchievementMarkedAsViewed(this.achievementId);

  @override
  List<Object?> get props => [achievementId];
}

class AchievementUnlocked extends AchievementState {
  final Achievement achievement;

  const AchievementUnlocked(this.achievement);

  @override
  List<Object?> get props => [achievement];
}

class NewAchievementsUnlocked extends AchievementState {
  final List<Achievement> achievements;

  const NewAchievementsUnlocked(this.achievements);

  @override
  List<Object?> get props => [achievements];
}

class AchievementProgress extends AchievementState {
  final String achievementId;
  final double progress;

  const AchievementProgress(this.achievementId, this.progress);

  @override
  List<Object?> get props => [achievementId, progress];
}

class AchievementViewed extends AchievementState {
  final String achievementId;

  const AchievementViewed(this.achievementId);

  @override
  List<Object?> get props => [achievementId];
} 