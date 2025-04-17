import 'package:flutter/widgets.dart';
import 'package:text_the_answer/config/colors.dart';

/// Custom widget to be used with a [Button] with [bottomNavigationBar] paramter
/// of a scaffold.
///
/// Wraps the button in a [DecoratedBox] with a top border and adds padding.
/// Support for bottom padding to accommodate the keyboard
///
class CustomBottomButtonWithDivider extends StatelessWidget {
  const CustomBottomButtonWithDivider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.white.withValues(alpha: 0.7),
            width: 0.7,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 40 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: child,
      ),
    );
  }
}

class TestCustomBottomButtonWithDivider extends StatelessWidget {
  const TestCustomBottomButtonWithDivider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.white.withValues(alpha: 0.7),
            width: 0.7,
          ),
        ),
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 30),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 40 + bottomInset,
        ),
        child: child,
      ),
    );
  }
}
