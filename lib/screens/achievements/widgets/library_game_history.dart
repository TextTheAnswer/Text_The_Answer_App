import 'package:flutter/material.dart';
import 'package:text_the_answer/screens/achievements/models/game_history_card_model.dart';
import 'package:text_the_answer/screens/achievements/widgets/game_history_card.dart';
import 'package:text_the_answer/shared/widgets/responsive_widget/max_width_responsive_container.dart';
import 'package:text_the_answer/utils/constants/breakpoint.dart';

class LibraryGameHistory extends StatelessWidget {
  const LibraryGameHistory({super.key, required this.gameHistorys});

  final List<GameHistoryCardModel> gameHistorys;

  @override
  Widget build(BuildContext context) {
    return MaxWidthResponsiveContainer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide = constraints.maxWidth > kTabletBreakingPoint;

          if (isWide) {
            return Scrollbar(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  mainAxisExtent: 170,
                ),
                itemCount: gameHistorys.length,
                itemBuilder: (context, index) {
                  return GameHistoryCard(cardModel: gameHistorys[index]);
                },
              ),
            );
          } else {
            return Scrollbar(
              child: ListView.builder(
                itemCount: gameHistorys.length,
                itemBuilder: (context, index) {
                  return GameHistoryCard(cardModel: gameHistorys[index]);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
