import 'package:flutter/material.dart';
import 'package:text_the_answer/screens/settings/widget/sub_settings_list_tile.dart';
import 'package:text_the_answer/utils/constants/breakpoint.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';

class MusicEffectScreen extends StatelessWidget {
  const MusicEffectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackArrow: true, title: Text('Music & Effects')),
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
                    SubSettingsListTile(title: 'Music'),

                    // -- Sound Effects
                    SubSettingsListTile(title: 'Sound Effects'),

                    // -- Animation Effects
                    SubSettingsListTile(title: 'Animation Effects'),

                    // -- Visual Effects
                    SubSettingsListTile(title: 'Visual Effects'),
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
