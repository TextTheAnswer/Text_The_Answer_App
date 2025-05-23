import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/blocs/auth/auth_bloc.dart';
import 'package:text_the_answer/blocs/auth/auth_event.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AppDrawer({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final accentColor =
        isDarkMode ? AppColors.darkOutlineBg : AppColors.lightOutlineBg;

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: accentColor.withValues(alpha: 0.2),
                    child: Icon(Icons.person, color: accentColor, size: 30),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Text the Answer',
                          style: FontUtility.montserratBold(
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Welcome!',
                          style: FontUtility.interRegular(
                            fontSize: 14,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(thickness: 1, color: textColor.withValues(alpha: 0.1)),

            // Drawer items
            _buildDrawerItem(
              context,
              icon: Icons.home,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   Routes.home,
                //   (route) => false,
                // );
                context.goNamed(AppRouteName.home);
              },
              textColor: textColor,
              accentColor: accentColor,
            ),

            _buildDrawerItem(
              context,
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                // Profile feature has been removed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile feature is currently unavailable'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              textColor: textColor,
              accentColor: accentColor,
            ),

            _buildDrawerItem(
              context,
              icon: Icons.lightbulb,
              title: 'Daily Quiz',
              onTap: () {
                Navigator.pop(context);
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   Routes.home,
                //   (route) => false,
                // );
                context.goNamed(AppRouteName.quiz);
              },
              textColor: textColor,
              accentColor: accentColor,
            ),

            _buildDrawerItem(
              context,
              icon: Icons.star,
              title: 'Premium Subscription',
              onTap: () {
                Navigator.pop(context);
                // Navigator.pushNamed(context, Routes.manageSubscription);
                // context.goNamed(AppRouteName.home);
              },
              textColor: textColor,
              accentColor: Colors.amber,
            ),

            _buildDrawerItem(
              context,
              icon: Icons.format_list_bulleted,
              title: 'Leaderboard',
              onTap: () {
                Navigator.pop(context);
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   Routes.home,
                //   (route) => false,
                // );
                // context.goNamed(AppRouteName.);
              },
              textColor: textColor,
              accentColor: accentColor,
            ),

            SizedBox(height: 16),
            Divider(thickness: 1, color: textColor.withValues(alpha: 0.1)),

            // Theme toggle
            _buildDrawerItem(
              context,
              icon: isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              title: isDarkMode ? 'Light Mode' : 'Dark Mode',
              onTap: () {
                // toggleTheme();
                Navigator.pop(context);
              },
              textColor: textColor,
              accentColor: accentColor,
            ),

            // Settings
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // Navigator.pushNamed(context, Routes.settings);
                context.pushNamed(AppRouteName.settings);
              },
              textColor: textColor,
              accentColor: accentColor,
            ),

            const Spacer(),

            Divider(thickness: 1, color: textColor.withValues(alpha: 0.1)),

            // Logout button at the bottom
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                _showLogoutDialog(context);
              },
              textColor: Colors.red.shade400,
              accentColor: Colors.red.shade400,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    required Color accentColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: accentColor, size: 24),
      title: Text(
        title,
        style: FontUtility.montserratMedium(fontSize: 16, color: textColor),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Dispatch logout event
                BlocProvider.of<AuthBloc>(context).add(SignOutEvent());
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close drawer
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
