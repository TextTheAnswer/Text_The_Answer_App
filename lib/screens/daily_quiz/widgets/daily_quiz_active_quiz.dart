// import 'package:flutter/material.dart';
// import 'package:text_the_answer/models/question.dart';

// class DailyQuizActiveQuiz extends StatelessWidget {
//   const DailyQuizActiveQuiz({super.key, required this.question});

//   final Question question;

//   @override
//   Widget build(BuildContext context) {
//     // Difficulty badge color
//     Color difficultyColor = Colors.green;
//     if (question.difficulty == 'medium') {
//       difficultyColor = Colors.orange;
//     } else if (question.difficulty == 'hard') {
//       difficultyColor = Colors.red;
//     }

//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // -- Difficulty badge
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: difficultyColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               question.difficulty.toUpperCase(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // -- Question text
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.1),
//                     blurRadius: 8,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       question.text,
//                       style: Theme.of(context).textTheme.headlineSmall,
//                     ),
//                     const SizedBox(height: 24),

//                     // Answer input field with typing indicator
//                     Column(
//                       children: [
//                         TextField(
//                           controller: _answerController,
//                           decoration: InputDecoration(
//                             hintText: 'Type your answer here...',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             filled: true,
//                             suffixIcon: IconButton(
//                               icon: Icon(Icons.send),
//                               onPressed:
//                                   () => _handleAnswerSubmission(
//                                     _answerController.text,
//                                   ),
//                             ),
//                           ),
//                           style: Theme.of(context).textTheme.titleMedium,
//                           onSubmitted: _handleAnswerSubmission,
//                           autofocus: true,
//                         ),
//                         const SizedBox(height: 8),
//                         // Add the typing progress indicator
//                         TypingProgressIndicator(
//                           controller: _answerController,
//                           maxWidth: MediaQuery.of(context).size.width - 64,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     Center(
//                       child: Text(
//                         'Type your answer and press Enter or tap Send',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     Center(
//                       child: Text(
//                         'Answer quickly for more points!',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
