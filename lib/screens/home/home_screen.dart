// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/screens/profile/profile_screen.dart';
import 'package:text_the_answer/utils/common_ui.dart';
import 'package:text_the_answer/utils/theme/theme_cubit.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import 'package:text_the_answer/widgets/bottom_nav_bar.dart';
import '../daily_quiz_screen.dart';
import '../game/game_mode_screen.dart';

@Deprecated('Use Home screen in /new_home_screen.dart. To be removed')
class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({required this.toggleTheme, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _toggleTheme() {
    // Get the current ThemeCubit and its state
    final ThemeCubit cubit = context.read<ThemeCubit>();
    final currentState = cubit.state;

    // Toggle between light and dark modes
    if (currentState.mode == AppThemeMode.dark) {
      cubit.setTheme(AppThemeMode.light);
    } else {
      cubit.setTheme(AppThemeMode.dark);
    }

    // Call the original toggleTheme callback
    widget.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to rebuild the entire widget when theme changes
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor =
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

        String title = 'Text the Answer';
        if (_currentIndex == 1) {
          title = 'Library';
        } else if (_currentIndex == 2) {
          title = 'Games';
        } else if (_currentIndex == 3) {
          title = 'Daily Quiz';
        } else if (_currentIndex == 4) {
          title = 'Profile';
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar:
              _currentIndex == 0
                  ? CustomAppBar(
                    showBackArrow: false,
                    title: Text('Text the Answer'),
                  )
                  : null,
          drawer: CommonUI.buildDrawer(
            context: context,
            toggleTheme: _toggleTheme,
            isDarkMode: isDarkMode,
          ),
          body: SafeArea(child: _buildCurrentScreen()),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTabContent();
      case 1:
        return const Center(child: Text('Library'));
      case 2:
        return GameModeScreen(toggleTheme: _toggleTheme);
      case 3:
        return DailyQuizScreen();
      // Profile is now a separate page with its own route
      default:
        return _buildHomeTabContent();
    }
  }

  void _onTabTapped(int index) {
    // If profile tab is clicked, navigate to the profile screen
    if (index == 4) {
      Navigator.pushNamed(context, Routes.profile);
      return;
    }

    // Otherwise, update the current tab index
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildHomeTabContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back! 👋',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Player Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: accentColor.withOpacity(0.2),
                  child: Icon(Icons.person, color: accentColor, size: 24.sp),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Stats Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Stats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        '24',
                        'Games Played',
                        Icons.gamepad,
                      ),
                      _buildStatItem(
                        context,
                        '18',
                        'Correct Answers',
                        Icons.check_circle,
                      ),
                      _buildStatItem(
                        context,
                        '320',
                        'Total Points',
                        Icons.star,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Daily Challenge
            Text(
              'Daily Challenge',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bolt,
                          color: accentColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pop Culture Quiz',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '10 questions · 5 min',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Complete today\'s challenge to earn bonus points!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                    child: Text('Start Challenge'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Recent Games
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Games',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(onPressed: () {}, child: Text('See All')),
              ],
            ),
            SizedBox(height: 16.h),
            _buildRecentGameItem(
              context,
              'Science Trivia',
              '8/10 correct',
              Icons.science,
              accentColor,
            ),
            SizedBox(height: 12.h),
            _buildRecentGameItem(
              context,
              'History Masters',
              '6/10 correct',
              Icons.history_edu,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: 20.sp),
        ),
        SizedBox(height: 8.h),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildRecentGameItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkLabelText : AppColors.lightLabelText;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: secondaryTextColor, size: 16.sp),
        ],
      ),
    );
  }
}
