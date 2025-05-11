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
  
  // Mock Data
  final String _userName = 'Alex Johnson';
  final String _userEmail = 'alex.johnson@example.com';
  final bool _isUserVerified = true;
  final String _userAvatar = 'https://i.pravatar.cc/150?img=12';
  final double _profileCompletionPercentage = 0.75;
  final bool _isPremiumUser = true;
  final String _subscriptionRenewalDate = '25 Dec 2023';
  final bool _autoRenewEnabled = true;
  
  // Stats
  final int _gamesPlayed = 24;
  final int _correctAnswers = 18;
  final int _totalPoints = 320;
  final int _currentStreak = 7;
  
  // Dummy streak data for chart
  final List<int> _streakHistory = [3, 4, 2, 5, 7, 6, 7];
  
  // Achievement badges
  final List<Map<String, dynamic>> _achievements = [
    {
      'name': 'Perfect Streak',
      'description': 'Maintained a 7-day streak without missing a quiz',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
      'earned': true,
      'date': '2023-11-15',
    },
    {
      'name': 'Quiz Master',
      'description': 'Achieved a perfect score in 5 consecutive quizzes',
      'icon': Icons.star,
      'color': Colors.amber,
      'earned': true,
      'date': '2023-11-10',
    },
    {
      'name': 'Fast Learner',
      'description': 'Completed 10 quizzes in a single day',
      'icon': Icons.bolt,
      'color': Colors.blue,
      'earned': true,
      'date': '2023-11-05',
    },
    {
      'name': 'Knowledge Seeker',
      'description': 'Answered 100 questions correctly',
      'icon': Icons.school,
      'color': Colors.green,
      'earned': false,
      'date': null,
    },
  ];
  
  // Recent activities
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'quiz_completed',
      'title': 'Completed Science Quiz',
      'description': 'Scored 8/10',
      'time': '2 hours ago',
      'icon': Icons.science,
      'color': Colors.blue,
    },
    {
      'type': 'subscription_renewed',
      'title': 'Premium Subscription Renewed',
      'description': 'Next renewal on Dec 25, 2023',
      'time': '1 day ago',
      'icon': Icons.card_membership,
      'color': Colors.amber,
    },
    {
      'type': 'badge_earned',
      'title': 'Earned Perfect Streak Badge',
      'description': 'Maintained a 7-day streak',
      'time': '3 days ago',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
    },
  ];
  
  // Educational info
  final Map<String, dynamic> _educationInfo = {
    'email': 'alex.j@university.edu',
    'year': '3rd Year',
    'verified': true,
    'institution': 'University of Technology',
  };
  
  // Social links
  final Map<String, String?> _socialLinks = {
    'twitter': '@alexjohnson',
    'linkedin': 'alex-johnson',
    'github': 'alexjdev',
  };
  
  // Recent games
  final List<Map<String, dynamic>> _recentGames = [
    {
      'title': 'Science Trivia',
      'subtitle': '8/10 correct',
      'icon': Icons.science,
      'category': 'science',
    },
    {
      'title': 'History Masters',
      'subtitle': '6/10 correct',
      'icon': Icons.history_edu,
      'category': 'history',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
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
              IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  // Toggle theme using context extension method
                  context.toggleTheme();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(context),
                  SizedBox(height: 24.h),
                  _buildStatsSection(context),
                  SizedBox(height: 24.h),
                  _buildAchievementsSection(context),
                  SizedBox(height: 24.h),
                  _buildRecentActivitySection(context),
                  SizedBox(height: 24.h),
                  _buildDailyChallengeSection(context),
                  SizedBox(height: 24.h),
                  _buildRecentGamesSection(context),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Show quick profile settings
              _showProfileSettingsModal(context);
            },
            child: Icon(Icons.settings),
            backgroundColor: accentColor,
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(BuildContext context) {
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
                    _userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isUserVerified)
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 20.sp,
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 4.h),
              
              // Email
              Text(
                _userEmail,
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
                      Text(
                        '${(_profileCompletionPercentage * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: _profileCompletionPercentage,
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
              if (_isPremiumUser)
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
                      value: _profileCompletionPercentage,
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
                          image: NetworkImage(_userAvatar),
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

  void _showProfileSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16.w),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Text(
                    'Profile Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  // Profile settings options would go here
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildStatsSection(BuildContext context) {
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
                        '$_currentStreak Day Streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Keep it going!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              
              // Streak chart
              SizedBox(
                height: 80.h,
                child: _buildStreakChart(context),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Stats grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              context,
              title: 'Games Played',
              value: _gamesPlayed.toString(),
              icon: Icons.gamepad,
              gradient: [Colors.purple.shade300, Colors.purple.shade600],
            ),
            _buildStatCard(
              context,
              title: 'Correct Answers',
              value: _correctAnswers.toString(),
              icon: Icons.check_circle,
              gradient: [Colors.green.shade300, Colors.green.shade600],
            ),
            _buildStatCard(
              context,
              title: 'Total Points',
              value: _totalPoints.toString(),
              icon: Icons.star,
              gradient: [Colors.amber.shade300, Colors.amber.shade600],
            ),
            _buildStatCard(
              context,
              title: 'Accuracy',
              value: '${(_correctAnswers * 100 / (_gamesPlayed * 10)).toInt()}%',
              icon: Icons.precision_manufacturing,
              gradient: [Colors.blue.shade300, Colors.blue.shade600],
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStreakChart(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        _streakHistory.length,
        (index) {
          final int value = _streakHistory[index];
          final double normalizedHeight = (value / _streakHistory.reduce(math.max)) * 60.h;
          
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
                // Navigate to all achievements
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
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              final achievement = _achievements[index];
              return _buildAchievementBadge(
                context,
                name: achievement['name'],
                description: achievement['description'],
                icon: achievement['icon'],
                color: achievement['color'],
                earned: achievement['earned'],
                date: achievement['date'],
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
              _isActivityExpanded ? _recentActivities.length : math.min(2, _recentActivities.length),
              (index) {
                final activity = _recentActivities[index];
                return _buildActivityItem(
                  context,
                  title: activity['title'],
                  description: activity['description'],
                  time: activity['time'],
                  icon: activity['icon'],
                  color: activity['color'],
                  isLast: index == (_isActivityExpanded 
                      ? _recentActivities.length - 1 
                      : math.min(2, _recentActivities.length) - 1),
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
  
  Widget _buildDailyChallengeSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Challenge',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade700,
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade700.withOpacity(0.3),
                blurRadius: 10.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bolt,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pop Culture Quiz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '10 questions · 5 min',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Body
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete today\'s challenge to earn bonus points!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Earn up to 100 bonus points',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Top 3 players get special badges',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        minimumSize: Size(double.infinity, 50.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'Start Challenge',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentGamesSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Games',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: Text('See All'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ..._recentGames.map((game) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildRecentGameItem(
              context,
              title: game['title'],
              subtitle: game['subtitle'],
              icon: game['icon'],
              category: game['category'],
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildRecentGameItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String category,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;
    
    // Determine color based on category
    Color iconColor;
    switch (category) {
      case 'science':
        iconColor = Colors.blue;
        break;
      case 'history':
        iconColor = Colors.amber;
        break;
      case 'literature':
        iconColor = Colors.green;
        break;
      case 'sports':
        iconColor = Colors.red;
        break;
      case 'entertainment':
        iconColor = Colors.purple;
        break;
      default:
        iconColor = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            // color: Cells.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'game_icon_$title',
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                // Navigate to game details
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: secondaryTextColor,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}