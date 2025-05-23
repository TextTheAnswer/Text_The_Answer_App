import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom App Bar
///
/// Parameters
/// - `title` - Widget to display at the main app bar content
/// - `showBackArrow' - Whether to show back arrow or not
/// - `leadingIcon` - IconData to be used if `showBackArrow` is `false`
/// - `actions` - List of widget to show on the left side of the app bar
/// - `onPressed` - Callback for when `leadingIcon` is passed and `showBackArrow` is false
/// - `bottom` - To use for tab and all
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    required this.showBackArrow,
    this.leadingIcon,
    this.actions,
    this.onPressed,
    this.bottom,
    this.shouldCenterTitle = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? onPressed;
  final PreferredSizeWidget? bottom;
  final bool shouldCenterTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: shouldCenterTitle,
        surfaceTintColor: Colors.transparent,
        leading:
            showBackArrow
                ? BackButton(onPressed: context.pop)
                : leadingIcon != null
                ? IconButton(onPressed: onPressed, icon: Icon(leadingIcon))
                : null,
        title: title,
        actions: actions,
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
