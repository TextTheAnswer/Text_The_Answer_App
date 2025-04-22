import 'package:flutter/material.dart';

/// Custom App Bar
///
/// Parameters
/// - `title` - Widget to display at the main app bar content
/// - `showBackArrow' - Whether to show back arrow or not
/// - `leadingIcon` - IconData to be used if `showBackArrow` is `false`
/// - `actions` - List of widget to show on the left side of the app bar
/// - `onPressed` - Callback for when `leadingIcon` is passed and `showBackArrow` is false
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    required this.showBackArrow,
    this.leadingIcon,
    this.actions,
    this.onPressed,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading:
            showBackArrow
                ? BackButton()
                : leadingIcon != null
                ? IconButton(onPressed: onPressed, icon: Icon(leadingIcon))
                : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
