import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../config/colors.dart';
import '../router/app_router.dart';
import '../router/routes.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SettingsScreen({required this.toggleTheme, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'default';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Initialize theme selection based on current theme state
    if (!_initialized) {
      // Get initial theme from AppRouter
      _selectedTheme = AppRouter.getCurrentTheme();
      _initialized = true;
    }
    
    // Always keep UI in sync with actual app theme
    if (_selectedTheme != AppRouter.getCurrentTheme()) {
      setState(() {
        _selectedTheme = AppRouter.getCurrentTheme();
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 20.h),
              
              // Settings List
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Account'),
                onTap: () {
                  // Navigate to account settings
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Subscription'),
                subtitle: const Text('Manage your premium subscription'),
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.manageSubscription);
                },
              ),
              
              // Theme Selection Dropdown
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme'),
                subtitle: const Text('Change app appearance'),
                trailing: DropdownButton<String>(
                  value: _selectedTheme,
                  underline: Container(),
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != _selectedTheme) {
                      // Update our local state first
                      setState(() {
                        _selectedTheme = newValue;
                      });
                      
                      // Then propagate the change to the app
                      try {
                        AppRouter.setTheme(newValue);
                      } catch (e) {
                        // Fallback to toggle if setTheme fails
                        widget.toggleTheme();
                        print('Error setting theme: $e');
                      }
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'default',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const Text('Default'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'dark',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: AppColors.darkBackground,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const Text('Dark'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'light',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: AppColors.lightBackground,
                              border: Border.all(color: Colors.grey),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const Text('Light'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  // Navigate to about screen
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  // Navigate to help screen
                },
              ),
              
              const Spacer(),
              
              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                  Navigator.pushReplacementNamed(context, Routes.login);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}