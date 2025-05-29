import 'package:flutter/material.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.buttonText,
    required this.buttonCallback,
    required this.cardTitle,
    required this.headerColor,
    required this.bodyColor,
    required this.headerIcon,
    required this.headerIconColor,
  });

  final String cardTitle;
  final Color headerColor;
  final IconData headerIcon;
  final Color headerIconColor;
  final Color bodyColor;
  final String buttonText;
  final VoidCallback buttonCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bodyColor,
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.only(right: 6),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: <Widget>[
          // -- Top Content
          SizedBox(
            width: 160,
            child: Container(
              decoration: BoxDecoration(color: headerColor),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  // -- Icon
                  Icon(headerIcon, color: headerIconColor, size: 40),

                  // -- Text
                  Text(cardTitle, style: TextStyle(fontSize: 30)),
                ],
              ),
            ),
          ),
          // -- Bottom content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // spacing: 10,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Limited quizes'),
                  Text('Basic stats'),
                  Text('Ad-supported'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
