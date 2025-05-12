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
        final primaryColor = isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
        final bgColor = isDarkMode ? Color(0xFF121212) : Color(0xFFF5F7FA);
        final cardColor = isDarkMode ? Color(0xFF1D1D1D) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            title: Row(
              children: [
                Text(
                  'Text',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'TheAnswer',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.verified,
                  color: Colors.amber,
                  size: 16.sp,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: textColor,
                ),
                onPressed: () {
                  // Show notifications
                },
              ),
            ],
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return _buildLoadingState();
              } else if (state is ProfileError) {
                return _buildErrorState(context, state.message);
              } else if (state is ProfileLoaded) {
                final ProfileData profile = state.profile;
                return _buildLoadedState(context, profile, isDarkMode, primaryColor, cardColor);
              } else {
                return _buildInitialState(context);
              }
            },
          ),
        );
      },
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text(
            'Loading your personalized experience...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(FetchProfileEvent());
              },
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to Text the Answer',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
  
  Widget _buildLoadedState(BuildContext context, ProfileData profile, bool isDarkMode, Color primaryColor, Color cardColor) {
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
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(FetchProfileEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              
              // Welcome message
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hello, ',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    TextSpan(
                      text: userName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 4.h),
              
              Text(
                'Ready to master your knowledge today?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Daily Quiz Countdown - Using the existing widget to maintain timer functionality
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: DailyQuizCountdown(
                  dailyQuizData: profile.dailyQuiz,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Quick Actions Row
              _buildQuickActionsRow(context, isDarkMode, primaryColor, cardColor),
              
              SizedBox(height: 24.h),
              
              // Category Section
              _buildCategorySection(context, isDarkMode, cardColor),
              
              SizedBox(height: 24.h),
              
              // Stats Section
              _buildStatsSection(
                context,
                streak: currentStreak,
                totalCorrect: totalCorrect,
                totalAnswered: totalAnswered,
                streakHistory: streakHistory,
                isDarkMode: isDarkMode,
              ),
              
              SizedBox(height: 24.h),
              
              // Achievements Section
              _buildAchievementsSection(context, isDarkMode, cardColor),
              
              SizedBox(height: 24.h),
              
              // Weekly Challenge Card
              _buildWeeklyChallengeCard(context, isDarkMode, primaryColor),
              
              SizedBox(height: 24.h),
              
              // Multiplayer button
              _buildMultiplayerButton(context, isDarkMode),
              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActionsRow(BuildContext context, bool isDarkMode, Color primaryColor, Color cardColor) {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.menu_book_outlined,
        'label': 'Library',
        'color': Colors.blue,
        'route': AppRoutePath.library,
      },
      {
        'icon': Icons.emoji_events_outlined,
        'label': 'Achievements',
        'color': Colors.amber,
        'route': AppRoutePath.achievements,
      },
      {
        'icon': Icons.bar_chart_outlined,
        'label': 'Leaderboard',
        'color': Colors.green,
        'route': AppRoutePath.leaderboard,
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'label': 'Premium',
        'color': Colors.deepPurple,
        'route': null,
      },
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {
            if (action['route'] != null) {
              context.go(action['route'] as String);
            }
          },
          child: Column(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 28.w,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                action['label'] as String,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildCategorySection(BuildContext context, bool isDarkMode, Color cardColor) {
    final categories = [
      {'name': 'Science', 'icon': Icons.science_outlined, 'color': Colors.teal},
      {'name': 'History', 'icon': Icons.history_edu_outlined, 'color': Colors.amber},
      {'name': 'Math', 'icon': Icons.calculate_outlined, 'color': Colors.blue},
      {'name': 'Geography', 'icon': Icons.public_outlined, 'color': Colors.green},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              'See All',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // Categories grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 1.5,
          children: categories.map((category) {
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 32.w,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildStatsSection(
    BuildContext context, {
    required int streak,
    required int totalCorrect,
    required int totalAnswered,
    required List<int> streakHistory,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Streak card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade600,
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
                      size: 24.sp,
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
            ],
          ),
        ),
        SizedBox(height: 16.h),
        
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _buildSimpleStatCard(
                context,
                title: 'Games Played',
                value: totalAnswered.toString(),
                icon: Icons.gamepad_outlined,
                color: Colors.blue,
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildSimpleStatCard(
                context,
                title: 'Correct',
                value: totalCorrect.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildSimpleStatCard(
                context,
                title: 'Accuracy',
                value: totalAnswered > 0 
                    ? '${(totalCorrect * 100 / totalAnswered).toInt()}%' 
                    : '0%',
                icon: Icons.analytics_outlined,
                color: Colors.amber,
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(child: Container()), // Empty space for balance
          ],
        ),
      ],
    );
  }
  
  Widget _buildSimpleStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
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
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsSection(BuildContext context, bool isDarkMode, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go(AppRoutePath.achievements);
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildAchievementItem(
                context,
                index: index,
                isDarkMode: isDarkMode,
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementItem(BuildContext context, {required int index, required bool isDarkMode}) {
    final List<Color> colors = [
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
    ];
    
    final List<IconData> icons = [
      Icons.emoji_events_outlined,
      Icons.psychology_outlined,
      Icons.directions_run_outlined,
      Icons.military_tech_outlined,
      Icons.lightbulb_outline,
    ];
    
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 16.w),
      child: Column(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[index % colors.length].withOpacity(0.1),
              border: Border.all(
                color: colors[index % colors.length],
                width: 2.w,
              ),
            ),
            child: Icon(
              icons[index % icons.length],
              color: colors[index % colors.length],
              size: 32.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Achievement ${index + 1}',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMultiplayerButton(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go(AppRoutePath.dailyQuizRealtime);
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups_outlined,
                  color: Colors.white,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Join Multiplayer Quiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWeeklyChallengeCard(BuildContext context, bool isDarkMode, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1D1D1D) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(isDarkMode ? 0.2 : 0),
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.star_border_rounded,
                    size: 24.sp,
                    color: Colors.purple,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'Weekly Challenge',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Test your knowledge in our special weekly themed quizzes! Complete challenges to earn exclusive badges and climb the leaderboard.',
            style: TextStyle(
              fontSize: 16.sp,
              color: isDarkMode ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                'Join This Week\'s Challenge',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  final bool isDarkMode;
  final Color dotColor;
  
  DotPatternPainter({
    required this.isDarkMode,
    required this.dotColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double dotSize = 2;
    final double spacing = 25;
    
    final Paint paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}