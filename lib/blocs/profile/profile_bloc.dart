import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/profile/profile_event.dart';
import 'package:text_the_answer/blocs/profile/profile_state.dart';
import 'package:text_the_answer/services/profile_service.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService _profileService = ProfileService();

  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(FetchProfileEvent event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoading) {
      // Prevent multiple simultaneous requests
      return;
    }
    
    emit(ProfileLoading());
    
    try {
      printDebug('ProfileBloc: Fetching profile data');
      final profile = await _profileService.getFullProfile();
      
      if (profile != null) {
        emit(ProfileLoaded(profile));
        printDebug('ProfileBloc: Successfully loaded profile data');
      } else {
        emit(ProfileError('Failed to fetch profile data'));
        printDebug('ProfileBloc: Profile data was null');
      }
    } catch (e) {
      if (kDebugMode) print('ProfileBloc Error (FetchProfileEvent): $e');
      
      // Check for authentication errors specifically
      if (e.toString().contains('Authentication token') || 
          e.toString().contains('Unauthorized') || 
          e.toString().contains('401')) {
        emit(ProfileAuthError('Authentication required. Please log in.'));
      } else {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    // Store current state to restore if update fails
    final currentState = state;
    
    // Don't show loading state but keep current data visible
    // Just set a flag in the state to show a loading indicator somewhere else in the UI
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.profile));
    } else {
      emit(ProfileLoading());
    }
    
    try {
      printDebug('ProfileBloc: Updating profile');
      final success = await _profileService.updateProfileInfo(
        name: event.name,
        bio: event.bio,
        location: event.location,
        imageUrl: event.imageUrl,
        favoriteCategories: event.favoriteCategories,
        notificationSettings: event.notificationSettings,
        displayTheme: event.displayTheme,
      );

      if (success) {
        // After successful update, fetch the latest profile data
        printDebug('ProfileBloc: Update successful, fetching updated profile');
        final profile = await _profileService.getFullProfile();
        
        if (profile != null) {
          emit(ProfileLoaded(profile));
          printDebug('ProfileBloc: Successfully reloaded profile after update');
        } else {
          // If we can't fetch the updated profile, at least keep the old one
          if (currentState is ProfileLoaded) {
            emit(ProfileLoaded(currentState.profile));
          } else {
            emit(ProfileError('Failed to fetch updated profile data'));
          }
        }
      } else {
        // If update failed, show error but keep current profile data
        if (currentState is ProfileLoaded) {
          emit(ProfileUpdateError('Failed to update profile', currentState.profile));
        } else {
          emit(ProfileError('Failed to update profile'));
        }
      }
    } catch (e) {
      if (kDebugMode) print('ProfileBloc Error (UpdateProfileEvent): $e');
      
      // If error occurred but we have previous data, keep it with an error message
      if (currentState is ProfileLoaded) {
        // Check for authentication errors specifically
        if (e.toString().contains('Authentication token') || 
            e.toString().contains('Unauthorized') || 
            e.toString().contains('401')) {
          emit(ProfileAuthError('Authentication required. Please log in.'));
        } else {
          emit(ProfileUpdateError(e.toString(), currentState.profile));
        }
      } else {
        if (e.toString().contains('Authentication token') || 
            e.toString().contains('Unauthorized') || 
            e.toString().contains('401')) {
          emit(ProfileAuthError('Authentication required. Please log in.'));
        } else {
          emit(ProfileError(e.toString()));
        }
      }
    }
  }
} 