import 'package:flutter/material.dart';
import 'package:text_the_answer/widgets/dividers/divider.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        // -- Divider
        Divider(),

        // -- Content 1
        Row(
          children: [
            //TODO: Create a data model to be passed in for the values for the content @shizzleclover
            // -- Quizo
            Expanded(
              child: _ProfileStatsContent(title: '45', contentTitle: 'Quizzo'),
            ),
            VerticalDividerWithHeight(),

            // -- Plays
            Expanded(
              child: _ProfileStatsContent(title: '5.6M', contentTitle: 'Plays'),
            ),
            VerticalDividerWithHeight(),

            // -- Players
            Expanded(
              child: _ProfileStatsContent(
                title: '16.8M',
                contentTitle: 'Players',
              ),
            ),
          ],
        ),

        // -- Divider
        Divider(),

        // -- Content 2
        Row(
          children: [
            // -- Collections
            Expanded(
              child: _ProfileStatsContent(
                title: '7',
                contentTitle: 'Collection',
              ),
            ),
            VerticalDividerWithHeight(),

            // -- Followers
            Expanded(
              child: _ProfileStatsContent(
                title: '372.5k',
                contentTitle: 'Followers',
              ),
            ),
            VerticalDividerWithHeight(),

            // -- Following
            Expanded(
              child: _ProfileStatsContent(
                title: '269',
                contentTitle: 'Following',
              ),
            ),
          ],
        ),

        // -- Divider
        Divider(),
      ],
    );
  }
}

class _ProfileStatsContent extends StatelessWidget {
  const _ProfileStatsContent({required this.title, required this.contentTitle});

  final String title;
  final String contentTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -- Title
        Text(title),
        SizedBox(height: 4),

        // -- Header
        Text(contentTitle),
      ],
    );
  }
}
