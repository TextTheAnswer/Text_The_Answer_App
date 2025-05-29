import 'package:flutter/material.dart';

/// A simple reusable widget for displaying empty or placeholder states
/// in the UI when there is no content to show.
///
/// Typically used when a list, feed, or section is empty, this widget
/// centers its contents and optionally shows an [icon], a [title], and
/// a [subtitle]. It helps communicate to the user that there's currently
/// nothing to display.
///
/// ### Example:
/// ```dart
/// EmptyStateContainer(
///   icon: Icons.inbox,
///   title: 'No items available',
///   subtitle: 'Try adding something new to get started.',
/// )
/// ```
///
/// The widget uses sensible padding and styling to ensure it blends well
/// with most UI designs.
///
/// {@tool snippet}
/// Use it inside any layout where you expect to handle empty content:
/// ```dart
/// body: items.isEmpty
///     ? EmptyStateContainer(
///         icon: Icons.list_alt,
///         title: 'No records found',
///         subtitle: 'Please check back later.',
///       )
///     : ListView(...),
/// ```
/// {@end-tool}
class EmptyStateContainer extends StatelessWidget {
  const EmptyStateContainer({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 80, color: Colors.grey),
            SizedBox(height: 16),

            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),

            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
