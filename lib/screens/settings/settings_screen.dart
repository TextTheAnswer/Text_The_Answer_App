import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:text_the_answer/screens/settings/widget/settings_list_tile.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../router/app_router.dart';
import '../../router/routes.dart';

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
      appBar: CustomAppBar(showBackArrow: true, title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Header
              _SettingsHeader(),

              // -- Personal info
              SettingsListTile(
                leadingIconColor: Colors.orange,
                leadingIcon: IconlyBold.profile,
                title: 'Personal Info',
                onTap: () {},
              ),

              // -- Notification
              SettingsListTile(
                leadingIconColor: Colors.red,
                leadingIcon: IconlyBold.notification,
                title: 'Notification',
                onTap: () {},
              ),

              // -- Music & Effects
              SettingsListTile(
                leadingIconColor: Colors.purple,
                leadingIcon: IconlyBold.volume_up,
                title: 'Music & Effects',
                onTap: () {},
              ),

              // -- Security
              SettingsListTile(
                leadingIconColor: Colors.green,
                leadingIcon: IconlyBold.shield_done,
                title: 'Security',
                onTap: () {},
              ),

              // -- Theme Selector
              SettingsListTile(
                leadingIconColor: Colors.blue,
                leadingIcon: IconlyBold.show,
                title: 'Appearance',
                extraValue: 'Default',
                trailingIcon: IconlyLight.more_circle,
                onTap: () {},
              ),

              // -- Help Center
              SettingsListTile(
                leadingIconColor: Colors.orange,
                leadingIcon: IconlyBold.paper,
                title: 'Help Center',
                onTap: () {},
              ),

              // -- About
              SettingsListTile(
                leadingIconColor: Colors.purple,
                leadingIcon: IconlyBold.info_square,
                title: 'About',
                onTap: () {},
              ),

              // -- Logout
              SettingsListTile(
                leadingIconColor: Colors.red,
                leadingIcon: IconlyBold.logout,
                title: 'Logout',
                trailingIcon: null,
                onTap: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                  Navigator.pushReplacementNamed(context, Routes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Play without ads and restrictions',
              style: FontUtility.montserratBold(fontSize: 24),
            ),
            Spacer(),

            GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Text('Go Premium', style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
