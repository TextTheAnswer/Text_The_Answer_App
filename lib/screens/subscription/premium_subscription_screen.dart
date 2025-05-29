import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:text_the_answer/screens/subscription/widgets/mountain_painter.dart';
import 'package:text_the_answer/screens/subscription/widgets/premium_card.dart';
import 'package:text_the_answer/shared/widgets/responsive_widget/max_width_responsive_container.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';

class PremiumSubscriptionScreen extends StatelessWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double size = 200;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        showBackArrow: true,
        leadingIcon: Icons.close,
        onPressed: context.pop,
      ),
      body: MaxWidthResponsiveContainer(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: [
                SizedBox(
                  height: size,
                  width: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: RoundedStarPainter(),
                        size: Size(100, 100),
                      ),

                      for (int i = 0; i < 8; i++)
                        Positioned(
                          left: size / 2 + 70 * cos(2 * pi * i / 8) - 10,
                          top: size / 2 + 70 * sin(2 * pi * i / 8) - 10,
                          child: Icon(
                            IconlyBold.star,
                            color: const Color.fromARGB(255, 100, 64, 180),
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),

                // -- Header
                Text('Go Premium', style: TextStyle(fontSize: 40)),

                PremiumCard(
                  cardTitle: 'Free',
                  headerColor: const Color.fromARGB(255, 31, 32, 36),
                  bodyColor: const Color.fromARGB(255, 39, 40, 44),
                  headerIcon: Icons.featured_play_list,
                  headerIconColor: const Color.fromARGB(255, 56, 55, 63),
                  buttonText: 'Current Plan',
                  buttonCallback: () {},
                ),
                PremiumCard(
                  cardTitle: 'Education',
                  headerColor: const Color.fromARGB(255, 36, 25, 70),
                  bodyColor: const Color.fromARGB(255, 44, 29, 78),
                  headerIcon: Icons.school,
                  headerIconColor: const Color.fromARGB(255, 68, 39, 159),
                  buttonText: 'Verify',
                  buttonCallback: () {},
                ),
                PremiumCard(
                  cardTitle: 'Premium',
                  headerColor: const Color.fromARGB(255, 38, 33, 105),
                  bodyColor: const Color.fromARGB(255, 45, 37, 125),
                  headerIcon: IconlyBold.star,
                  headerIconColor: Colors.amber,
                  buttonText: 'Ugrade',
                  buttonCallback: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
