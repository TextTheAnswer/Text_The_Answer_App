import 'package:flutter/material.dart';

/// A custom 3D button widget
/// Replacement for [SocialButton]
///
/// TODO: Improve the API to work as a generate button through the app @danielkiing3
class Custom3DButton extends StatefulWidget {
  const Custom3DButton({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.duration = const Duration(milliseconds: 160),
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.semanticsLabel,
  });

  /// Widget to display inside the button
  final Widget child;

  /// Background color of the button
  final Color backgroundColor;

  /// Duration of the button press animation
  final Duration duration;

  /// Callback function to be called when the button is pressed
  final VoidCallback onPressed;

  /// Padding around the button content
  final EdgeInsets padding;

  /// Border radius of the button
  final BorderRadius borderRadius;

  /// Semantics label for the button
  final String? semanticsLabel;

  @override
  State<Custom3DButton> createState() => _Custom3DButtonState();
}

class _Custom3DButtonState extends State<Custom3DButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pressedAnimation;

  static const double _buttonDepth = 8.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(microseconds: widget.duration.inMicroseconds ~/ 2),
    );

    _pressedAnimation = Tween<double>(
      begin: -_buttonDepth,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();

  void _onTapUp(_) async {
    widget.onPressed();

    if (!_controller.isCompleted) {
      await _controller.forward();
    }
    if (!mounted) return;
    await _controller.reverse();
  }

  void _onTapCancel() => _controller.reverse();

  /// This method takes the current color (from the `backgroundColor` property)
  /// and modifies its hue, saturation, and lightness by the specified amounts.
  Color _hslRelativeColor({double h = 0.0, s = 0.0, l = 0.0}) {
    final hsl = HSLColor.fromColor(widget.backgroundColor);
    return HSLColor.fromAHSL(
      hsl.alpha,
      (hsl.hue + h).clamp(0.0, 360.0),
      (hsl.saturation + s).clamp(0.0, 1.0),
      (hsl.lightness + l).clamp(0.0, 1.0),
    ).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel ?? 'Press to perform action',
      button: true,
      onTap: widget.onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _pressedAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // -- Shadow layer
                Positioned.fill(
                  top: _buttonDepth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _hslRelativeColor(s: -0.2, l: -0.25),
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                ),

                // -- Top button
                Transform.translate(
                  offset: Offset(0, _pressedAnimation.value),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: widget.borderRadius,
                    ),
                    child: Padding(
                      padding: widget.padding,
                      child: Center(child: widget.child),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
