import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/blocs/auth/auth_bloc.dart';
import 'package:text_the_answer/blocs/auth/auth_state.dart';
import 'package:text_the_answer/blocs/profile/profile_bloc.dart';
import 'package:text_the_answer/blocs/profile/profile_event.dart';
import 'package:text_the_answer/blocs/profile/profile_state.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/screens/profile/edit_profile_screen.dart';
import 'package:text_the_answer/screens/profile/widgets/profile_header.dart';
import 'package:text_the_answer/screens/profile/widgets/stats_card.dart';
import 'package:text_the_answer/screens/profile/widgets/subscription_info_card.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';
import 'package:text_the_answer/widgets/error_widget.dart';
import 'package:text_the_answer/widgets/loading_widget.dart';
import 'package:text_the_answer/utils/theme/theme_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
    
    // We'll load the profile data after checking auth state in build
  }
  
  void _loadProfileData() {
    // Get the current auth state before loading profile
    final authState = context.read<AuthBloc>().state;
    
    if (authState is AuthAuthenticated) {
      printDebug('User is authenticated, loading profile data');
      _profileBloc.add(FetchProfileEvent());
    } else {
      printDebug('User is not authenticated, cannot load profile data');
      // Don't try to load profile if not authenticated
    }
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.mode == AppThemeMode.dark;
          
          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthAuthenticated) {
                // When auth state changes to authenticated, load profile data
                _loadProfileData();
              }
            },
            builder: (context, authState) {
              // Check if we're authenticated
              final isAuthenticated = authState is AuthAuthenticated;
              
              // If this is the first build and we're already authenticated, load profile
              if (isAuthenticated && _profileBloc.state is ProfileInitial) {
                _loadProfileData();
              }
              
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Profile',
                    style: FontUtility.montserratBold(
                      fontSize: 20.sp,
                      color: isDarkMode ? Colors.white : AppColors.darkGray,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () {
                        context.pushNamed(AppRouteName.settings);
                      },
                    ),
                  ],
                ),
                body: !isAuthenticated 
                  ? _buildAuthRequiredView(isDarkMode)
                  : RefreshIndicator(
                    onRefresh: () async {
                      _loadProfileData();
                    },
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoading) {
                          return const LoadingWidget();
                        } else if (state is ProfileAuthError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.sp,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Authentication Error',
                                  style: FontUtility.montserratBold(
                                    fontSize: 18.sp,
                                    color: isDarkMode ? Colors.white : AppColors.darkGray,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                                  child: Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: FontUtility.interRegular(
                                      fontSize: 14.sp,
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                ElevatedButton(
                                  onPressed: () {
                                    context.goNamed(AppRouteName.login);
                                  },
                                  child: Text('Go to Login'),
                                ),
                              ],
                            ),
                          );
                        } else if (state is ProfileError) {
                          return CustomErrorWidget(
                            message: state.message,
                            onRetry: _loadProfileData,
                          );
                        } else if (state is ProfileLoaded || state is ProfileUpdating || state is ProfileUpdateError) {
                          // Get the profile data regardless of which state we're in
                          final profile = state is ProfileLoaded 
                              ? state.profile 
                              : state is ProfileUpdating 
                                  ? state.profile
                                  : (state as ProfileUpdateError).profile;
                              
                          // Show error message if we're in update error state
                          if (state is ProfileUpdateError) {
                            // Show a snackbar with the error message
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            });
                          }
                          
                          // Show loading indicator in the app bar if updating
                          final bool isUpdating = state is ProfileUpdating;
                              
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Show updating indicator if needed
                                if (isUpdating)
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                    margin: EdgeInsets.only(bottom: 16.h),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16.w,
                                          height: 16.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.w,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Updating profile...',
                                          style: FontUtility.interRegular(
                                            fontSize: 14.sp,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                // Profile header with user details
                                ProfileHeader(
                                  profile: profile,
                                  isDarkMode: isDarkMode,
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                // Stats card showing user's statistics
                                StatsCard(
                                  stats: profile.stats,
                                  isDarkMode: isDarkMode,
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                // Subscription information
                                SubscriptionInfoCard(
                                  subscription: profile.subscription,
                                  isPremium: profile.isPremium,
                                  isDarkMode: isDarkMode,
                                  onManageSubscription: () {
                                    // Navigate to subscription management
                                    context.pushNamed(AppRouteName.settings);
                                  },
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                // Edit profile button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 18.sp,
                                    ),
                                    onPressed: () {
                                      // Navigate to edit profile screen
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditProfileScreen(
                                            profile: profile,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      side: BorderSide(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.2),
                                      ),
                                    ),
                                    label: Text(
                                      'Edit Profile',
                                      style: FontUtility.montserratMedium(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 40.h),
                              ],
                            ),
                          );
                        }
                        
                        // Initial state or unknown state
                        return Center(
                          child: ElevatedButton(
                            onPressed: _loadProfileData,
                            child: Text('Load Profile'),
                          ),
                        );
                      },
                    ),
                  ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildAuthRequiredView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64.sp,
            color: isDarkMode ? Colors.white54 : Colors.black38,
          ),
          SizedBox(height: 24.h),
          Text(
            'Authentication Required',
            style: FontUtility.montserratBold(
              fontSize: 20.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'Please sign in to view your profile information.',
              textAlign: TextAlign.center,
              style: FontUtility.interRegular(
                fontSize: 16.sp,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () {
              context.goNamed(AppRouteName.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Go to Login',
              style: FontUtility.montserratBold(
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 