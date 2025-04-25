import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:text_the_answer/screens/settings/widget/sub_settings_list_tile.dart';
import 'package:text_the_answer/utils/constants/app_images.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text('About TextTheAnswer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Header
              const SizedBox(height: 30),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // -- App Logo
                    Image.asset(AppImages.appLogo, width: 120, height: 120),
                    const SizedBox(height: 20),

                    // -- Version number
                    Text('TextTheAnswer v5.32.3ß'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -- Divider
              Divider(),

              // -- Job Vacancy
              SubSettingsListTile(
                title: 'Job Vacancy',
                onTap: () {},
                trailingIcon: IconsaxPlusLinear.arrow_right_3,
              ),

              // -- Fees
              SubSettingsListTile(
                title: 'Fees',
                onTap: () {},
                trailingIcon: IconsaxPlusLinear.arrow_right_3,
              ),

              // -- Developer
              SubSettingsListTile(
                title: 'Developer',
                onTap: () {},
                trailingIcon: IconsaxPlusLinear.arrow_right_3,
              ),

              //-- Add more
            ],
          ),
        ),
      ),
    );
  }
}
