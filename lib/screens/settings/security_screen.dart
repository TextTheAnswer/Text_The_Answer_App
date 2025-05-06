import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/screens/settings/widget/sub_settings_list_tile.dart';
import 'package:text_the_answer/utils/constants/breakpoint.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import 'package:text_the_answer/widgets/custom_3d_button.dart';
import 'package:text_the_answer/widgets/custom_bottom_button_with_divider.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackArrow: true, title: Text('Security')),
      bottomNavigationBar: CustomBottomButtonWithDivider(
        child: Custom3DButton(
          backgroundColor: AppColors.buttonSecondary,
          onPressed: () {},
          borderRadius: BorderRadius.circular(100),
          child: Text('Change Password'),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: kMaxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Music
                    SubSettingsListTile(title: 'Remember me'),

                    // -- Sound Effects
                    SubSettingsListTile(title: 'Biometric ID'),

                    // -- Face ID
                    SubSettingsListTile(title: 'Face ID'),

                    // -- SMS Authenticator
                    SubSettingsListTile(title: 'SMS Authenticator'),

                    // -- Google Authenticator
                    SubSettingsListTile(title: 'Google Authenticator'),

                    // -- Visual Effects
                    SubSettingsListTile(
                      title: 'Device Management',
                      trailingIcon: IconsaxPlusLinear.arrow_right_3,
                    ),

                    // -- Change Email
                    SubSettingsListTile(
                      title: 'Change Email',
                      trailingIcon: IconsaxPlusLinear.arrow_right_3,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
