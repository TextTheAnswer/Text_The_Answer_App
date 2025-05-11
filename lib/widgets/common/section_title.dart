import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;

  const SectionTitle({
    Key? key,
    required this.title,
    this.style,
    this.trailing,
    this.onTrailingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: style ?? 
                Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: trailing!,
            ),
        ],
      ),
    );
  }
} 