import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/utils/theme/theme_cubit.dart';
import 'package:text_the_answer/widgets/bottom_sheet/bottom_sheet_shell.dart';
import 'package:text_the_answer/widgets/button/on_tap_scaler.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  final AppThemeMode selectedMode;

  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return BottomSheetShell(
      headerText: 'Appearance',
      children: [
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            for (final mode in AppThemeMode.values)
              Flexible(
                child: _Item(
                  icon: switch (mode) {
                    AppThemeMode.defaultTheme => IconsaxPlusBold.lamp,
                    AppThemeMode.light => IconsaxPlusBold.danger,
                    AppThemeMode.dark => IconsaxPlusBold.lamp_charge,
                  },
                  title: switch (mode) {
                    AppThemeMode.defaultTheme => 'Default',
                    AppThemeMode.light => 'Light',
                    AppThemeMode.dark => 'Dark',
                  },
                  isSelected: mode == selectedMode,
                  onTap: () {
                    if (selectedMode != mode) {
                      onChanged(mode);
                    }
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;

  final String title;

  final bool isSelected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OnTapScaler(
      onTap: onTap,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(
            width: 4,
            color: isSelected ? AppColors.buttonPrimary : Colors.transparent,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey, //TODO: Use a good color
            borderRadius: const BorderRadius.all(Radius.circular(18)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // -- Icon
                Icon(icon),

                // -- Text
                Text(title, overflow: TextOverflow.clip, maxLines: 1),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
