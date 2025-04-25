import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/widgets/button/on_tap_scaler.dart';

class SubSettingsListTile extends StatelessWidget {
  const SubSettingsListTile({
    super.key,
    required this.title,
    this.trailingIcon,
    this.onTap,
  });

  //TODO: Finalize the api
  final String title;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  Widget _buildSwitch() {
    if (Platform.isIOS) {
      return CupertinoSwitch(
        value: true,
        onChanged: (val) {},
        activeTrackColor: AppColors.buttonPrimary,
      );
    } else {
      return Switch(
        value: true,
        onChanged: (val) {},
        activeTrackColor: AppColors.buttonPrimary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnTapScaler(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // -- Title
            Text(title),

            // -- Toggle
            if (trailingIcon != null) Icon(trailingIcon),
            if (trailingIcon == null) _buildSwitch(),
          ],
        ),
      ),
    );
  }
}
