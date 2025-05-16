import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/screens/main_app_screen.dart';
import 'package:text_the_answer/utils/constants/breakpoint.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import 'package:text_the_answer/blocs/profile/profile_bloc.dart';
import 'package:text_the_answer/blocs/profile/profile_event.dart';
import 'package:text_the_answer/blocs/profile/profile_state.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/widgets/quiz/daily_quiz_countdown_content.dart';
import 'package:text_the_answer/widgets/quiz/profile_header.dart';
import '../../router/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: false,
        leadingIcon: Icons.menu,
        onPressed: () {
          AppScaffoldKeys.mainScaffoldKey.currentState?.openDrawer();
        },
        title: Text(
          'Text the Answer',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
        ),
        actions: [
          IconButton(icon: Icon(IconlyLight.search), onPressed: () {}),
          IconButton(icon: Icon(IconlyLight.notification), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error loading profile data',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
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
              final String userAvatar =
                  profile.profile.imageUrl.isNotEmpty
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

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isWide =
                      constraints.maxWidth > kTabletBreakingPoint;

                  return isWide
                      ? Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: kMaxContentWidth,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: <Widget>[
                                        // -- Daily Quiz Countdown
                                        DailyQuizCountdownContent(
                                          dailyQuizData: profile.dailyQuiz,
                                        ),
                                        SizedBox(height: 24),

                                        // -- Profile Header
                                        ProfileHeader(
                                          userName: userName,
                                          email: userEmail,
                                          avaterUrl: userAvatar,
                                          isPremium: isPremiumUser,
                                        ),
                                        SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),

                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: <Widget>[
                                        _buildStatsSection(
                                          context,
                                          streak: currentStreak,
                                          totalCorrect: totalCorrect,
                                          totalAnswered: totalAnswered,
                                          streakHistory: streakHistory,
                                        ),
                                        SizedBox(height: 24),
                                        _buildAchievementsSection(context),
                                        SizedBox(height: 24),
                                        _buildRecentActivitySection(context),
                                        SizedBox(height: 24),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.go(
                                              AppRoutePath.dailyQuizRealtime,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.group),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Join Daily Multiplayer Quiz',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // -- Daily Quiz Countdown
                              DailyQuizCountdownContent(
                                dailyQuizData: profile.dailyQuiz,
                              ),
                              SizedBox(height: 24),

                              // -- Profile Header
                              ProfileHeader(
                                userName: userName,
                                email: userEmail,
                                avaterUrl: userAvatar,
                                isPremium: isPremiumUser,
                              ),

                              SizedBox(height: 24),
                              _buildStatsSection(
                                context,
                                streak: currentStreak,
                                totalCorrect: totalCorrect,
                                totalAnswered: totalAnswered,
                                streakHistory: streakHistory,
                              ),
                              SizedBox(height: 24),
                              _buildAchievementsSection(context),
                              SizedBox(height: 24),
                              _buildRecentActivitySection(context),
                              SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  context.go(AppRoutePath.dailyQuizRealtime);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
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
                },
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
                    SizedBox(height: 16),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }
          },
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
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Stats', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 16),

        // Streak card with chart
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.7),
                accentColor.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak Day Streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Keep it up!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: _buildStreakChart(context, streakHistory),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

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
            SizedBox(width: 16),
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
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Accuracy',
                value:
                    totalAnswered > 0
                        ? '${(totalCorrect * 100 / totalAnswered).toInt()}%'
                        : '0%',
                icon: Icons.precision_manufacturing,
                gradient: [Colors.amber.shade300, Colors.amber.shade600],
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: Container()), // Empty space for balance
          ],
        ),
      ],
    );
  }

  Widget _buildStreakChart(BuildContext context, List<int> streakHistory) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(streakHistory.length, (index) {
        final int value = streakHistory[index];
        final double normalizedHeight =
            (value / streakHistory.reduce(math.max)) * 60;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 20,
              height: normalizedHeight,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'D${index + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show detailed stats
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 30),
                SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
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
            Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                // Navigate to the achievements library page
                context.go(AppRoutePath.library);
              },
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 16),

        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
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
        width: 100,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Badge icon container
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    earned
                        ? color.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                border: Border.all(
                  color: earned ? color : Colors.grey,
                  width: 2,
                ),
                boxShadow:
                    earned
                        ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                        : [],
              ),
              child: Icon(icon, color: earned ? color : Colors.grey, size: 36),
            ),
            SizedBox(height: 8),

            // Badge name
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color:
                    earned
                        ? isDarkMode
                            ? Colors.white
                            : Colors.black
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.1),
                    border: Border.all(color: color, width: 3),
                  ),
                  child: Icon(icon, color: color, size: 40),
                ),
                SizedBox(height: 16),
                Text(
                  name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Earned on ${_formatDate(date)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: Size(double.infinity, 50),
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _isActivityExpanded = !_isActivityExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  children: [
                    Text(
                      _isActivityExpanded ? 'Collapse' : 'Expand',
                      style: TextStyle(color: accentColor),
                    ),
                    Icon(
                      _isActivityExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: accentColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              _isActivityExpanded
                  ? 5
                  : 2, // Placeholder for actual implementation
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor.withValues(alpha: 0.7),
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
