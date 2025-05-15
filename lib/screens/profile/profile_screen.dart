import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:text_the_answer/blocs/auth/auth_bloc.dart';
import 'package:text_the_answer/blocs/auth/auth_state.dart';
import 'package:text_the_answer/blocs/profile/profile_bloc.dart';
import 'package:text_the_answer/blocs/profile/profile_event.dart';
import 'package:text_the_answer/blocs/profile/profile_state.dart';
import 'package:text_the_answer/blocs/achievement/achievement_bloc.dart';
import 'package:text_the_answer/blocs/achievement/achievement_event.dart';
import 'package:text_the_answer/blocs/achievement/achievement_state.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/screens/profile/edit_profile_screen.dart';
import 'package:text_the_answer/screens/profile/widgets/profile_achievement_section.dart';
import 'package:text_the_answer/screens/profile/widgets/stats_card.dart';
import 'package:text_the_answer/screens/profile/widgets/subscription_info_card.dart';
import 'package:text_the_answer/screens/profile/widgets/uploading_profile_loader.dart';
import 'package:text_the_answer/utils/constants/breakpoint.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';
import 'package:text_the_answer/widgets/error_widget.dart';
import 'package:text_the_answer/widgets/loading_widget.dart';

import 'widgets/profile_header/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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

      // Also load user achievements
      context.read<AchievementBloc>().add(LoadUserAchievements());
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _profileBloc,
      child: BlocConsumer<AuthBloc, AuthState>(
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
                style: FontUtility.montserratBold(fontSize: 20),
              ),
              centerTitle: false,
              actions: [
                // -- Settings
                IconButton(
                  icon: Icon(IconlyLight.setting),
                  onPressed: () => context.pushNamed(AppRouteName.settings),
                ),
              ],
            ),
            body:
                !isAuthenticated
                    ? SafeArea(child: _buildAuthRequiredView(isDarkMode))
                    : SafeArea(
                      child: RefreshIndicator(
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
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Authentication Error',
                                      style: FontUtility.montserratBold(
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 32,
                                      ),
                                      child: Text(
                                        state.message,
                                        textAlign: TextAlign.center,
                                        style: FontUtility.interRegular(
                                          fontSize: 14,
                                          color:
                                              isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
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
                            } else if (state is ProfileLoaded ||
                                state is ProfileUpdating ||
                                state is ProfileUpdateError) {
                              // Get the profile data regardless of which state we're in
                              final profile =
                                  state is ProfileLoaded
                                      ? state.profile
                                      : state is ProfileUpdating
                                      ? state.profile
                                      : (state as ProfileUpdateError).profile;

                              // Show error message if we're in update error state
                              if (state is ProfileUpdateError) {
                                // Show a snackbar with the error message
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
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

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide =
                                      constraints.maxWidth >
                                      kTabletBreakingPoint;

                                  return isWide
                                      ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    if (isUpdating)
                                                      UploadingProfileLoader(),
                                                    const SizedBox(height: 8),
                                                    // -- Profile Header
                                                    LandscapeProfileHeader(
                                                      profile: profile,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Divider(
                                                      color:
                                                          !isDarkMode
                                                              ? Colors.black
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  )
                                                              : Colors.white
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  ),
                                                    ),
                                                    const SizedBox(height: 8),

                                                    // -- Subscription card
                                                    SubscriptionInfoCard(
                                                      subscription:
                                                          profile.subscription,
                                                      isPremium:
                                                          profile.isPremium,
                                                      isDarkMode: isDarkMode,
                                                      onManageSubscription: () {
                                                        context.pushNamed(
                                                          AppRouteName.settings,
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(height: 20),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            Expanded(
                                              flex: 2,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    // -- Achievements
                                                    _buildAchievementsSection(),
                                                    SizedBox(height: 24),

                                                    // -- Stats Card
                                                    StatsCard(
                                                      stats: profile.stats,
                                                    ),
                                                    SizedBox(height: 40),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : SingleChildScrollView(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: SafeArea(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Show updating indicator if needed
                                              if (isUpdating)
                                                UploadingProfileLoader(),

                                              PortraitProfileHeader(
                                                profile: profile,
                                                onEditPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              EditProfileScreen(
                                                                profile:
                                                                    profile,
                                                              ),
                                                    ),
                                                  ).then(
                                                    (_) => _loadProfileData(),
                                                  );
                                                },
                                              ),

                                              SizedBox(height: 24),
                                              Divider(
                                                color:
                                                    !isDarkMode
                                                        ? Colors.black
                                                            .withValues(
                                                              alpha: 0.2,
                                                            )
                                                        : Colors.white
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                              ),

                                              // Add achievements section
                                              _buildAchievementsSection(),
                                              SizedBox(height: 24),

                                              // Stats card showing user's statistics
                                              StatsCard(stats: profile.stats),
                                              SizedBox(height: 24),

                                              // Subscription information
                                              SubscriptionInfoCard(
                                                subscription:
                                                    profile.subscription,
                                                isPremium: profile.isPremium,
                                                isDarkMode: isDarkMode,
                                                onManageSubscription: () {
                                                  context.pushNamed(
                                                    AppRouteName.settings,
                                                  );
                                                },
                                              ),
                                              SizedBox(height: 40),
                                            ],
                                          ),
                                        ),
                                      );
                                },
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
                    ),
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
            size: 64,
            color: isDarkMode ? Colors.white54 : Colors.black38,
          ),
          SizedBox(height: 24),
          Text(
            'Authentication Required',
            style: FontUtility.montserratBold(
              fontSize: 20,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Please sign in to view your profile information.',
              textAlign: TextAlign.center,
              style: FontUtility.interRegular(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.goNamed(AppRouteName.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Go to Login',
              style: FontUtility.montserratBold(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // New method to build the achievements section
  Widget _buildAchievementsSection() {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        // Loading state
        if (state is AchievementLoading) {
          return _buildSectionCard(
            title: 'Achievements',
            child: SizedBox(
              height: 70,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Error state
        if (state is AchievementError) {
          return _buildSectionCard(
            title: 'Achievements',
            child: SizedBox(
              height: 70,
              child: Center(
                child: Text(
                  'Could not load achievements',
                  style: FontUtility.interRegular(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }

        if (state is UserAchievementsLoaded) {
          return ProfileAchievementSection(
            achievements: state.achievements,
            unviewedAchievements: state.unviewedAchievements,
          );
        }

        // Default view if no state matches
        return _buildSectionCard(
          title: 'Achievements',
          child: SizedBox(
            height: 70,
            child: Center(
              child: Text(
                'Complete quizzes to earn achievements!',
                style: FontUtility.interRegular(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build consistent section cards
  Widget _buildSectionCard({
    required String title,
    required Widget child,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: FontUtility.montserratBold(fontSize: 18)),
                if (actionText != null && onActionTap != null)
                  GestureDetector(
                    onTap: onActionTap,
                    child: Text(
                      actionText,
                      style: FontUtility.interMedium(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
