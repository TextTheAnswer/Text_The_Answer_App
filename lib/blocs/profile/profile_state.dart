import 'package:text_the_answer/models/profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileData profile;

  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

// Authentication error specific state
class ProfileAuthError extends ProfileState {
  final String message;

  ProfileAuthError(this.message);
}

// State when profile is being updated but we still want to show existing data
class ProfileUpdating extends ProfileState {
  final ProfileData profile;

  ProfileUpdating(this.profile);
}

// Error during update but we still have the profile data
class ProfileUpdateError extends ProfileState {
  final String message;
  final ProfileData profile;

  ProfileUpdateError(this.message, this.profile);
} 