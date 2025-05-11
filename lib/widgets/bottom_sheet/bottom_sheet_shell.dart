import 'package:flutter/material.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class BottomSheetShell extends StatelessWidget {
  const BottomSheetShell({
    super.key,
    required this.headerText,
    required this.children,
    this.headerTextColor,
  });

  final String headerText;
  final Color? headerTextColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: isDarkMode ? Color(0xFF1F222A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 386),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Header
                Center(
                  child: Text(
                    headerText,
                    style: FontUtility.montserrat(
                      color: headerTextColor,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // -- Divider
                Divider(),
                const SizedBox(height: 20),

                // --
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
