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
            // -- Drawer header
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

            // Scrollable middle content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // -- Home
                    _DrawerItem(
                      icon: Icons.home,
                      title: 'Home',
                      onTap: () {
                        context.pop();
                        context.goNamed(AppRouteName.home);
                      },
                      textColor: textColor,
                      accentColor: accentColor,
                    ),

                    // -- Profile
                    _DrawerItem(
                      icon: Icons.person,
                      title: 'Profile',
                      onTap: () {
                        context.pop();
                        context.goNamed(AppRouteName.profile);
                      },
                      textColor: textColor,
                      accentColor: accentColor,
                    ),

                    // -- Daily Quiz
                    _DrawerItem(
                      icon: Icons.lightbulb,
                      title: 'Daily Quiz',
                      onTap: () {
                        context.pop();
                        context.goNamed(AppRouteName.quiz);
                      },
                      textColor: textColor,
                      accentColor: accentColor,
                    ),

                    // -- Premium Sub
                    _DrawerItem(
                      icon: Icons.star,
                      title: 'Premium Subscription',
                      onTap: () {
                        context.pop();
                        //TODO: Navigate to premium sub screen
                      },
                      textColor: textColor,
                      accentColor: Colors.amber,
                    ),

                    // -- Leaderboard
                    _DrawerItem(
                      icon: Icons.format_list_bulleted,
                      title: 'Leaderboard',
                      onTap: () {
                        context.pop();
                        //TODO: To be implemented
                      },
                      textColor: textColor,
                      accentColor: accentColor,
                    ),

                    // -- Settings
                    _DrawerItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () => context.pushNamed(AppRouteName.settings),
                      textColor: textColor,
                      accentColor: accentColor,
                    ),
                  ],
                ),
              ),
            ),

            Divider(thickness: 1, color: textColor.withValues(alpha: 0.1)),

            // Logout button at the bottom
            _DrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                _showLogoutDialog(context);
              },
              textColor: Colors.red.shade400,
              accentColor: Colors.red.shade400,
            ),
          ],
        ),
      ),
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color textColor;
  final Color accentColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: accentColor, size: 24),
      title: Text(
        title,
        style: FontUtility.montserratMedium(fontSize: 16, color: textColor),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
