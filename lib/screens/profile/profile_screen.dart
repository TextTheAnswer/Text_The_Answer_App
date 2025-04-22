import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../config/colors.dart';
import '../../models/user_profile_model.dart';
import '../../models/profile_model.dart';
import '../../router/routes.dart';
import '../../services/profile_service.dart';
import '../../utils/common_ui.dart';
import '../../utils/font_utility.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';
import 'edit_profile_screen.dart';
import 'game_history_screen.dart';
import 'streak_progress_screen.dart';

// Extension method to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class ProfileScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const ProfileScreen({required this.toggleTheme, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  UserProfileFull? _userProfile;
  Profile? _basicProfile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchProfile();
  }

  Future<void> _checkAuthAndFetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAuth = await _profileService.isAuthenticated();

      if (isAuth) {
        // User is authenticated, fetch profile using the updated endpoint
        await _fetchBasicProfile();
      } else {
        // User is not authenticated, don't try to fetch profile
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    }
  }

  // New method to fetch basic profile from /api/auth/profile
  Future<void> _fetchBasicProfile() async {
    try {
      final response = await _profileService.getProfile();
      
      if (kDebugMode) {
        print(
          'ProfileScreen: Basic profile fetch response - ${response.success}',
        );
      }
      
      if (response.success && response.profile != null) {
        // Store the basic profile
        _basicProfile = response.profile;
        
        // Once we have the basic profile, fetch the full profile
        await _fetchUserProfile();
      } else {
        setState(() {
          _isLoading = false;
          _basicProfile = null;
          
          if (response.message.toLowerCase().contains('not found')) {
            _errorMessage = 'Profile not found. Please create your profile.';
          } else if (response.message.toLowerCase().contains('auth')) {
            _errorMessage = 'Authentication required. Please login again.';
          } else {
            _errorMessage = response.message;
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _basicProfile = null;
        _errorMessage =
            'An error occurred while fetching profile: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await _profileService.getFullProfile();
      setState(() {
        _isLoading = false;
        if (response.success && response.profile != null) {
          _userProfile = response.profile;
          _errorMessage = null; // Clear any previous error
        } else if (response.message?.toLowerCase().contains('no profile') ??
            false) {
          // User is authenticated but doesn't have a full profile yet
          // We might still have the basic profile from _fetchBasicProfile
          _userProfile = null;
          // Only set error message if we don't have basic profile
          if (_basicProfile == null) {
            _errorMessage = 'Profile not found. Please create your profile.';
          } else {
            _errorMessage = null; // We'll show the basic profile instead
          }
        } else {
          // There's an error but we might still have basic profile
          _errorMessage = response.message ?? 'Failed to load complete profile';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Only set error message if we don't have basic profile
        if (_basicProfile == null) {
          _errorMessage = 'An error occurred: ${e.toString()}';
        } else {
          // We have basic profile, so we'll show that instead
          _errorMessage =
              'Failed to load complete profile. Showing basic information.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: false,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(IconsaxPlusLinear.send_2)),
          IconButton(
            onPressed: () {},
            icon: Icon(IconsaxPlusLinear.message_notif),
          ),
          IconButton(onPressed: () {}, icon: Icon(IconsaxPlusLinear.setting_2)),
        ],
        title: Row(
          children: [
            // -- Logo
            Image.asset(AppImages.appLogo, height: kToolbarHeight - 10),
            SizedBox(width: 24),

            // -- Text
            Text(
              'Profile',

              style: FontUtility.interRegular(
                fontSize: 24,
                //TODO: Checking for dark mode should be in a central location
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
      drawer: CommonUI.buildDrawer(
        context: context,
        toggleTheme: widget.toggleTheme,
        isDarkMode: isDarkMode,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Loading state
            if (state is AuthLoading || _isLoading) {
              return const Center(child: CircularProgressIndicator());
            } 
            // Authenticated
            else if (state is AuthAuthenticated) {
              // Check if we have any profile data
              if (_userProfile != null) {
                // Show full profile
                return _buildProfileContent();
            } else if (_basicProfile != null) {
                // Show basic profile if available
                return _buildBasicProfileContent();
            } else if (_errorMessage != null) {
                // Show error message when no profile data is available
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        CustomButton(
                          text: 'Retry',
                          onPressed: _checkAuthAndFetchProfile,
                          bgColor: AppColors.primary,
                          icon: Icons.refresh,
                        ),
                        SizedBox(height: 12.h),
                        if (_errorMessage!.toLowerCase().contains('not found') ||
                           _errorMessage!.toLowerCase().contains('create'))
                          CustomButton(
                            text: 'Create Profile',
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.profileCreate);
                            },
                            bgColor: Colors.green,
                            icon: Icons.person_add,
                          ),
                        if (_errorMessage!.toLowerCase().contains('auth') ||
                            _errorMessage!.toLowerCase().contains('login') ||
                            _errorMessage!.toLowerCase().contains('token'))
                          CustomButton(
                            text: 'Login',
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.login);
                            },
                            buttonType: CustomButtonType.outline,
                            borderColor: AppColors.primary,
                            textColor: AppColors.primary,
                            icon: Icons.login,
                          ),
                      ],
                    ),
                  ),
                );
            } else {
                // No profile data and no errors - show create profile view
                return _buildNoProfileView();
              }
            }
            // Not authenticated
            else {
              return _buildNotLoggedInView();
            }
          },
      ),
    );
  }

  Widget _buildProfileContent() {
    final profile = _userProfile!;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _checkAuthAndFetchProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            SizedBox(height: 24.h),

            // Profile Card
            ProfileCard(profile: profile),
            SizedBox(height: 24.h),

            // Stats Card
            _buildStatsCard(profile.stats),
            SizedBox(height: 24.h),

            // Buttons
            _buildActionButtons(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(UserStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Stats', style: FontUtility.montserratBold(fontSize: 18)),
            SizedBox(height: 16.h),

            // Stats Grid
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  label: 'Streak',
                  value: '${stats.streak} days',
                ),
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                  label: 'Correct',
                  value: '${stats.totalCorrect}',
                ),
                _buildStatItem(
                  icon: Icons.auto_graph,
                  iconColor: Colors.blue,
                  label: 'Accuracy',
                  value: stats.accuracy,
                ),
              ],
            ),

            // Last Played
            if (stats.lastPlayed != null)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Text(
                      'Last played: ${_formatDate(stats.lastPlayed!)}',
                      style: FontUtility.interRegular(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(value, style: FontUtility.montserratBold(fontSize: 16)),
          SizedBox(height: 4.h),
          Text(
            label,
            style: FontUtility.interRegular(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: 'Edit Profile',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => EditProfileScreen(profileDetails: _userProfile!),
              ),
            );
          },
          bgColor: AppColors.primary,
          icon: Icons.edit,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          text: 'Game History',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => GameHistoryScreen(toggleTheme: widget.toggleTheme),
              ),
            );
          },
          bgColor: Colors.blue,
          icon: Icons.history,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          text: 'Streak Progress',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        StreakProgressScreen(toggleTheme: widget.toggleTheme),
              ),
            );
          },
          bgColor: Colors.orange,
          icon: Icons.local_fire_department,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          text: 'Toggle Theme',
          onPressed: widget.toggleTheme,
          buttonType: CustomButtonType.outline,
          icon: Icons.brightness_4,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 80.sp, color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'You are not logged in',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            'Sign in to access your profile, track your progress, and unlock premium features',
            style: FontUtility.interRegular(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: 'LOG IN',
            onPressed: () {
              Navigator.pushNamed(context, Routes.login);
            },
            bgColor: AppColors.primary,
            icon: Icons.login,
          ),
          SizedBox(height: 12.h),
          CustomButton(
            text: 'SIGN UP',
            onPressed: () {
              Navigator.pushNamed(context, Routes.signup);
            },
            buttonType: CustomButtonType.outline,
            borderColor: AppColors.primary,
            textColor: AppColors.primary,
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Icon(
                Icons.person_add_alt_rounded,
                size: 80.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Complete Your Profile',
              style: FontUtility.montserratBold(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'Your account is ready, but your profile is not set up yet. Create your profile to personalize your experience!',
              style: FontUtility.interRegular(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: 'CREATE PROFILE',
              onPressed: () {
                Navigator.pushNamed(context, Routes.profileCreate);
              },
              bgColor: AppColors.primary,
              icon: Icons.create_rounded,
              buttonSize: CustomButtonSize.large,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                // Navigate back to home tab
                Navigator.pop(context);
              },
              child: Text(
                'Skip for now',
                style: FontUtility.interRegular(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to display basic profile if full profile fails
  Widget _buildBasicProfileContent() {
    final profile = _basicProfile!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final textColor =
        isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
    
    return RefreshIndicator(
      onRefresh: _checkAuthAndFetchProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            // Profile Header
            Text('Profile 👤', style: theme.textTheme.headlineLarge),
            SizedBox(height: 24.h),

            // Basic Profile Card
            Card(
              elevation: 4,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Center(
                      child: Column(
                        children: [
                          ProfileImage(imageUrl: profile.imageUrl),
                          SizedBox(height: 16.h),
                          if (profile.bio != null && profile.bio!.isNotEmpty)
                            Text(
                              profile.bio!,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Location if available
                    if (profile.location != null &&
                        profile.location!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18.sp,
                              color: textColor.withOpacity(0.7),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                profile.location!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Preferences if available
                    if (profile.preferences != null)
                      Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preferences',
                              style: theme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 8.h),
                            
                            // Favorite categories
                            if (profile.preferences!.favoriteCategories !=
                                    null &&
                                profile
                                    .preferences!
                                    .favoriteCategories!
                                    .isNotEmpty)
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children:
                                    profile.preferences!.favoriteCategories!
                                        .map(
                                          (category) => Chip(
                                          label: Text(category),
                                            backgroundColor: accentColor
                                                .withOpacity(0.1),
                                            labelStyle: TextStyle(
                                              color: accentColor,
                                            ),
                                          ),
                                        )
                                    .toList(),
                              ),
                            
                            // Display theme preference
                            if (profile.preferences!.displayTheme != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Row(
                                  children: [
                                    Icon(
                                      profile.preferences!.displayTheme ==
                                              'dark'
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      size: 18.sp,
                                      color: textColor.withOpacity(0.7),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Theme: ${profile.preferences!.displayTheme!.capitalize()}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),

            // Action Buttons
            _buildActionButtons(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
