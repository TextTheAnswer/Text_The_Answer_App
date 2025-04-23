import 'package:flutter/material.dart';

/// Custom Vertical divider with height property
class VerticalDividerWithHeight extends StatelessWidget {
  const VerticalDividerWithHeight({super.key, this.height = 60});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: VerticalDivider());
  }
}
