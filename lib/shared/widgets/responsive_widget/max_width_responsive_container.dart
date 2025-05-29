import 'package:flutter/material.dart';
import 'package:text_the_answer/utils/constants/breakpoint.dart';

///
/// A responsive container that centers its child and constrains its maximum width.
///
/// `MaxWidthResponsiveContainer` is useful for layouts that should remain
/// centered and constrained on wide screens (such as tablets or desktops),
/// while still being responsive on smaller devices.
///
/// This widget does the following:
/// - Wraps the child in a [SafeArea] to respect notches and insets.
/// - Centers the child horizontally using [Align] with [Alignment.topCenter].
/// - Constrains the maximum width of the content using [ConstrainedBox] with
///   a max width of [kMaxContentWidth].
class MaxWidthResponsiveContainer extends StatelessWidget {
  /// Creates a [MaxWidthResponsiveContainer] with the given [child].
  ///
  /// See class-level documentation for layout behavior and usage example.
  const MaxWidthResponsiveContainer({super.key, required this.child});

  /// The widget to display inside the constrained container.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kMaxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
