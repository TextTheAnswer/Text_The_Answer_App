import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:text_the_answer/widgets/button/on_tap_scaler.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.title,
    required this.leadingIconColor,
    required this.leadingIcon,
    this.onTap,
    this.extraValue,
    this.trailingIcon = IconsaxPlusLinear.arrow_right_3,
    this.leadingSize = 50.0,
    this.leadingIconSize = 24.0,
  });

  final String title;
  final Color leadingIconColor;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  final String? extraValue;
  final IconData? trailingIcon;

  final double leadingSize;
  final double leadingIconSize;

  Color _getBackgroundColor(Color color) {
    return HSLColor.fromColor(color).withAlpha(0.2).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return OnTapScaler(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // -- Icon Header
            Container(
              height: leadingSize,
              width: leadingSize,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getBackgroundColor(leadingIconColor),
                shape: BoxShape.circle,
              ),
              child: Icon(
                leadingIcon,
                color: leadingIconColor,
                size: leadingIconSize,
              ),
            ),
            SizedBox(width: 12),

            // -- Title and extra value
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (extraValue != null)
                    Text(
                      extraValue!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // -- Trailling
            if (trailingIcon != null) Icon(trailingIcon),
          ],
        ),
      ),
    );
  }
}
