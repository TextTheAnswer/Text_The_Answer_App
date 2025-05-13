import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/screens/main_app_screen.dart';
import 'package:text_the_answer/utils/theme/theme_cubit.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import 'package:text_the_answer/widgets/common/theme_aware_widget.dart';
import 'package:text_the_answer/widgets/quiz/event_countdown.dart';
import 'package:text_the_answer/widgets/quiz/waiting_room.dart';
import 'package:text_the_answer/utils/quiz/time_utility.dart';
import 'package:text_the_answer/screens/daily_quiz_screen.dart';
import 'package:text_the_answer/blocs/profile/profile_bloc.dart';
import 'package:text_the_answer/blocs/profile/profile_event.dart';
import 'package:text_the_answer/blocs/profile/profile_state.dart';
import 'package:text_the_answer/widgets/quiz/daily_quiz_countdown.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Animation controller for microinteractions
  late AnimationController _animationController;
  
  // Expanded section states
  bool _isPremiumBenefitsExpanded = false;
  bool _isActivityExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Fetch profile data when the screen loads
    context.read<ProfileBloc>().add(FetchProfileEvent());
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeAwareWidget(
      builder: (context, themeState) {
        final isDarkMode = themeState.themeData.brightness == Brightness.dark;
        final secondaryTextColor =
            isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;
        final cardColor =
            isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
        final accentColor =
            isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;

        return Scaffold(
          appBar: CustomAppBar(
            showBackArrow: false,
            leadingIcon: Icons.menu,
            onPressed: () {
              AppScaffoldKeys.mainScaffoldKey.currentState?.openDrawer();
            },
            title: Text('Text the Answer'),
            actions: [
              // IconButton(
              //   icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              //   onPressed: () {
              //     // Toggle theme using context extension method
              //     context.toggleTheme();
              //   },
              // ),
            ],
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ProfileError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64.sp, color: Colors.red),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading profile data',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProfileBloc>().add(FetchProfileEvent());
                          },
                          child: Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is ProfileLoaded) {
                final ProfileData profile = state.profile;
                
                // Extract real data from the profile
                final String userName = profile.name;
                final String userEmail = profile.email;
                final bool isPremiumUser = profile.isPremium;
                final String userAvatar = profile.profile.imageUrl.isNotEmpty
                    ? profile.profile.imageUrl
                    : 'https://i.pravatar.cc/150?img=12'; // Fallback avatar
                
                // Extract stats
                final int currentStreak = profile.stats.streak;
                final int totalCorrect = profile.stats.totalCorrect;
                final int totalAnswered = profile.stats.totalAnswered;
                final String accuracy = profile.stats.accuracy;
                
                // Create streakHistory (mock if not available)
                final List<int> streakHistory = [
                  math.max(1, currentStreak - 6),
                  math.max(1, currentStreak - 5),
                  math.max(1, currentStreak - 3),
                  math.max(1, currentStreak - 2),
                  math.max(1, currentStreak - 1),
                  currentStreak,
                  currentStreak,
                ];
                
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // -- Daily Quiz Countdown
                        DailyQuizCountdownContent(
                          dailyQuizData: profile.dailyQuiz,
                        ),
                        SizedBox(height: 24.h),
                        
                        _buildProfileCard(
                          context, 
                          userName: userName,
                          userEmail: userEmail,
                          userAvatar: userAvatar,
                          isPremiumUser: isPremiumUser,
                        ),
                        SizedBox(height: 24.h),
                        _buildStatsSection(
                          context,
                          streak: currentStreak,
                          totalCorrect: totalCorrect,
                          totalAnswered: totalAnswered,
                          streakHistory: streakHistory,
                        ),
                        SizedBox(height: 24.h),
                        _buildAchievementsSection(context),
                        SizedBox(height: 24.h),
                        _buildRecentActivitySection(context),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            context.go(AppRoutePath.dailyQuizRealtime);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group),
                              const SizedBox(width: 8),
                              Text('Join Daily Multiplayer Quiz'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Initial state or unknown state
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to Text the Answer',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16.h),
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
  
  Widget _buildProfileCard(
    BuildContext context, {
    required String userName,
    required String userEmail,
    required String userAvatar,
    required bool isPremiumUser,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner Image
        Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.7),
                accentColor.withOpacity(0.3),
              ],
            ),
          ),
        ),
        
        // Profile Card
        Container(
          margin: EdgeInsets.only(top: 60.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 40.h), // Space for the avatar
              
              // Name and verification
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 4.h),
              
              // Email
              Text(
                userEmail,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Profile completion progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile Completion',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: 0.75, // Placeholder for actual implementation
                      backgroundColor: accentColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      minHeight: 8.h,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Social media links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    icon: Icons.alternate_email,
                    color: Colors.blue.shade400,
                    onTap: () {
                      // Open Twitter profile
                    },
                  ),
                  _buildSocialButton(
                    icon: Icons.link,
                    color: Colors.blue.shade700,
                    onTap: () {
                      // Open LinkedIn profile
                    },
                  ),
                  _buildSocialButton(
                    icon: Icons.code,
                    color: Colors.grey.shade800,
                    onTap: () {
                      // Open GitHub profile
                    },
                  ),
                ],
              ),
              
              // Premium badge
              if (isPremiumUser)
                Container(
                  margin: EdgeInsets.only(top: 16.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade300, Colors.amber.shade700],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Profile Avatar with progress ring
        Positioned(
          top: 40.h, // Center avatar between banner and card
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 80.w,
              height: 80.w,
              child: Stack(
                children: [
                  // Progress ring
                  SizedBox(
                    width: 80.w,
                    height: 80.w,
                    child: CircularProgressIndicator(
                      value: 0.75, // Placeholder for actual implementation
                      strokeWidth: 4.w,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                  
                  // Avatar
                  Center(
                    child: Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cardColor,
                          width: 3.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(userAvatar),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Handle error loading image
                          },
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(35.r),
                          onTap: () {
                            // Show profile picture options
                          },
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                  
                  // Edit button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cardColor,
                          width: 2.w,
                        ),
                      ),
                      child: IconButton(
                        iconSize: 16.sp,
                        padding: EdgeInsets.all(4.w),
                        constraints: BoxConstraints(),
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          // Show profile picture edit options
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context, {
    required int streak,
    required int totalCorrect,
    required int totalAnswered,
    required List<int> streakHistory,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        
        // Streak card with chart
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.7),
                accentColor.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak Day Streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Keep it up!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 80.h,
                child: _buildStreakChart(context, streakHistory),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        
        // Stats grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Games Played',
                value: totalAnswered.toString(),
                icon: Icons.gamepad,
                gradient: [Colors.purple.shade300, Colors.purple.shade600],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Correct Answers',
                value: totalCorrect.toString(),
                icon: Icons.check_circle,
                gradient: [Colors.green.shade300, Colors.green.shade600],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Accuracy',
                value: totalAnswered > 0 
                    ? '${(totalCorrect * 100 / totalAnswered).toInt()}%' 
                    : '0%',
                icon: Icons.precision_manufacturing,
                gradient: [Colors.amber.shade300, Colors.amber.shade600],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(child: Container()), // Empty space for balance
          ],
        ),
      ],
    );
  }
  
  Widget _buildStreakChart(BuildContext context, List<int> streakHistory) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        streakHistory.length,
        (index) {
          final int value = streakHistory[index];
          final double normalizedHeight = (value / streakHistory.reduce(math.max)) * 60.h;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 20.w,
                height: normalizedHeight,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'D${index + 1}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12.sp,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show detailed stats
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 30.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAchievementsSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Navigate to the achievements library page
                context.go(AppRoutePath.library);
              },
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: 5, // Placeholder for actual implementation
            itemBuilder: (context, index) {
              return _buildAchievementBadge(
                context,
                name: 'Achievement ${index + 1}',
                description: 'Description for Achievement ${index + 1}',
                icon: Icons.star,
                color: Colors.amber,
                earned: true,
                date: '2023-11-${index + 5}',
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementBadge(
    BuildContext context, {
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required bool earned,
    String? date,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    
    return GestureDetector(
      onTap: () {
        if (earned) {
          _showAchievementDetails(
            context,
            name: name,
            description: description,
            icon: icon,
            color: color,
            date: date!,
          );
        }
      },
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            // Badge icon container
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: earned ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                border: Border.all(
                  color: earned ? color : Colors.grey,
                  width: 2.w,
                ),
                boxShadow: earned
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: earned ? color : Colors.grey,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 8.h),
            
            // Badge name
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: earned 
                    ? isDarkMode ? Colors.white : Colors.black 
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAchievementDetails(
    BuildContext context, {
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required String date,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                    border: Border.all(
                      color: color,
                      width: 3.w,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 40.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Earned on ${_formatDate(date)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: Size(double.infinity, 50.h),
                  ),
                  child: Text('Awesome!'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
  
  Widget _buildRecentActivitySection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                setState(() {
                  _isActivityExpanded = !_isActivityExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Text(
                      _isActivityExpanded ? 'Collapse' : 'Expand',
                      style: TextStyle(
                        color: accentColor,
                      ),
                    ),
                    Icon(
                      _isActivityExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: accentColor,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              _isActivityExpanded ? 5 : 2, // Placeholder for actual implementation
              (index) {
                return _buildActivityItem(
                  context,
                  title: 'Activity ${index + 1}',
                  description: 'Description for Activity ${index + 1}',
                  time: '${index + 1} hours ago',
                  icon: Icons.star,
                  color: Colors.amber,
                  isLast: index == (_isActivityExpanded ? 4 : 1),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;
        
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: secondaryTextColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}