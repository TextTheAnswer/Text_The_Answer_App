import 'package:flutter/material.dart';
import 'package:text_the_answer/screens/settings/widget/sub_settings_list_tile.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackArrow: true, title: Text('Notifications')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Enable Push Notification
              SubSettingsListTile(title: 'Enable Push Notifications'),

              // -- New Followers
              SubSettingsListTile(title: 'New Followers'),

              // -- New Likes
              SubSettingsListTile(title: 'New Likes'),

              // -- Payment & Subscriptions
              SubSettingsListTile(title: 'Payment & Subscriptions'),

              // -- Friend Activity
              SubSettingsListTile(title: 'Friend Activity'),

              // -- Leaderboard
              SubSettingsListTile(title: 'Leaderboard'),

              // -- App Updates
              SubSettingsListTile(title: 'App Updates'),

              // -- News & Promotion
              SubSettingsListTile(title: 'News & Promotion'),

              // -- New Tips Available
              SubSettingsListTile(title: 'New Tips Available'),

              // -- Survey Invitation
              SubSettingsListTile(title: 'Survey Invitation'),
            ],
          ),
        ),
      ),
    );
  }
}
