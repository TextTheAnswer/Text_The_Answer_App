import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:text_the_answer/screens/achievements/models/game_history_card_model.dart';

/// Component for displaying game history
///
/// Takes in a GameHistoryCardModel for ui
class GameHistoryCard extends StatelessWidget {
  const GameHistoryCard({super.key, required this.cardModel});

  final GameHistoryCardModel cardModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color:
            isDark
                ? const Color.fromARGB(255, 45, 51, 65)
                : const Color.fromARGB(255, 155, 157, 159),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              // -- Quiz Icon Type
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 27, 31, 38),
                ),
                child: Center(
                  child: Text(
                    cardModel.headerIcon,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),

              // -- History Body
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Quiz title
                    Text(
                      cardModel.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),

                    // -- Score ccount
                    Text(
                      '🎯 Score: ${cardModel.score}',
                      style: TextStyle(fontSize: 16),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // -- Duration and Date
                        Expanded(
                          child: Text(
                            '⏰ ${cardModel.duration} - ${cardModel.date}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),

                        // -- View Details
                        TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Text(
                                'View Details',
                                style: TextStyle(color: colorScheme.primary),
                              ),
                              Icon(
                                IconlyLight.arrow_right_2,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
