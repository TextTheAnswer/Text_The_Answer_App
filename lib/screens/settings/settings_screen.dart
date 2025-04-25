import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:text_the_answer/models/profile_model.dart';
import 'package:text_the_answer/models/user_profile_model.dart';
import 'package:text_the_answer/router/custom_bottom_sheet_route.dart';
import 'package:text_the_answer/screens/profile/edit_profile_screen.dart';
import 'package:text_the_answer/screens/settings/about_screen.dart';
import 'package:text_the_answer/screens/settings/help_center_screen.dart';
import 'package:text_the_answer/screens/settings/music_effect_screen.dart';
import 'package:text_the_answer/screens/settings/notification_screen.dart';
import 'package:text_the_answer/screens/settings/security_screen.dart';
import 'package:text_the_answer/screens/settings/widget/logout_bottom_sheet_content.dart';
import 'package:text_the_answer/screens/settings/widget/settings_list_tile.dart';
import 'package:text_the_answer/screens/settings/widget/theme_switcher.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/utils/theme/theme_cubit.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import '../../router/app_router.dart';

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
                onTap: () {
                  //TODO: Pass the details through the constructor or refactor
                  // EditProfileScreen to acess details from a state provider
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EditProfileScreen(
                            profileDetails: UserProfileFull(
                              id: 'Testing',
                              email: '@superhim',
                              name: 'Daniel Olayinka',
                              profile: Profile(
                                id: 'Testing',
                                bio: 'A love gaming',
                                location: 'London',
                                imageUrl: '',
                              ),
                              subscription: Subscription(status: ''),
                              stats: UserStats(),
                              isPremium: true,
                              isEducation: false,
                            ),
                          ),
                    ),
                  );
                },
              ),

              // -- Notification
              SettingsListTile(
                leadingIconColor: Colors.red,
                leadingIcon: IconlyBold.notification,
                title: 'Notification',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => NotificationScreen()),
                  );
                },
              ),

              // -- Music & Effects
              SettingsListTile(
                leadingIconColor: Colors.purple,
                leadingIcon: IconlyBold.volume_up,
                title: 'Music & Effects',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MusicEffectScreen()),
                  );
                },
              ),

              // -- Security
              SettingsListTile(
                leadingIconColor: Colors.green,
                leadingIcon: IconlyBold.shield_done,
                title: 'Security',
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => SecurityScreen()));
                },
              ),

              // -- Theme Selector
              SettingsListTile(
                leadingIconColor: Colors.blue,
                leadingIcon: IconlyBold.show,
                title: 'Appearance',
                extraValue: BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return Text(switch (state.mode) {
                      AppThemeMode.defaultTheme => 'Default',
                      AppThemeMode.light => 'Light',
                      AppThemeMode.dark => 'Dark',
                    });
                  },
                ),
                trailingIcon: IconlyLight.more_circle,
                onTap: _showThemeSwitcher,
              ),

              // -- Help Center
              SettingsListTile(
                leadingIconColor: Colors.orange,
                leadingIcon: IconlyBold.paper,
                title: 'Help Center',
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => HelpCenterScreen()));
                },
              ),

              // -- About
              SettingsListTile(
                leadingIconColor: Colors.purple,
                leadingIcon: IconlyBold.info_square,
                title: 'About',
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => AboutScreen()));
                },
              ),

              // -- Logout
              SettingsListTile(
                leadingIconColor: Colors.red,
                leadingIcon: IconlyBold.logout,
                title: 'Logout',
                trailingIcon: null,
                onTap: _showLogoutModal,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutModal() async {
    await showCustomBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          minimum: const EdgeInsets.only(bottom: 4),
          child: LogoutBottomSheetContent(),
        );
      },
    );
  }

  Future<void> _showThemeSwitcher() async {
    await showCustomBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          minimum: const EdgeInsets.only(bottom: 4),
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return ThemeSwitcher(
                selectedMode: state.mode,
                onChanged: context.read<ThemeCubit>().setTheme,
              );
            },
          ),
        );
      },
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
