# Daily Quiz Feature

## Overview

The Daily Quiz is a real-time, text-based quiz competition where users compete simultaneously to answer 10 questions. The quiz runs once per day at 9 AM UTC.

## Components

### Screens

- **DailyQuizHomeScreen**: Entry point that displays information about the upcoming quiz.
- **DailyQuizRealtimeScreen**: The main quiz experience screen that handles socket communication.
- **QuizReviewScreen**: Screen for reviewing questions after the quiz is completed.

### BLoCs

- **DailyQuizBloc**: Manages the state of the real-time quiz experience.
- **SocketBloc**: Handles socket connection and general socket events.
- **AchievementBloc**: Manages achievement unlocking and tracking.

### Services

- **DailyQuizSocket**: Service for socket.io communication specific to the daily quiz.
- **AuthTokenService**: Handles authentication for socket connections.

## Technical Flow

1. **Initialization**:
   - The app connects to the socket.io server when the user navigates to the DailyQuizRealtimeScreen.
   - The `SocketBloc` is responsible for establishing the base socket connection.
   - The `DailyQuizBloc` uses the `DailyQuizSocket` service to handle quiz-specific socket events.

2. **Socket Communication**:
   - The daily quiz uses the `/daily-quiz` namespace on the socket.io server.
   - Authentication is handled by including the user's token in the socket connection options.
   - The app relies on real-time events from the server to update the UI.

3. **Event Flow**:
   - User joins the quiz room via the `join-event` event.
   - Server sends a `new-question` event when a new question is available.
   - User submits answer via the `submit-answer` event.
   - Server responds with an `answer-result` event containing the result.
   - Server periodically sends `leaderboard-update` events.
   - After all questions, the server sends a `quiz-ended` event.

4. **Achievement Integration**:
   - When a quiz is completed, the app checks for achievement criteria.
   - If criteria are met, it dispatches an `UnlockAchievement` event to the `AchievementBloc`.
   - New achievements are displayed on the quiz completion screen.

5. **Social Sharing**:
   - The quiz results can be shared using the `share_plus` package.
   - The `QuizShareCard` widget provides a UI for sharing options.

## Maintenance Guide

### Adding New Question Types

Currently, the quiz supports text-based answers. To add new question types:

1. Update the `Question` model in `lib/models/question.dart`.
2. Add the new question type enum value.
3. Update the UI in `DailyQuizRealtimeScreen` to handle the new question type.
4. Update the answer validation logic in the `DailyQuizBloc`.

### Modifying Achievement Criteria

To change or add achievement criteria for the daily quiz:

1. Edit the `_checkAndUnlockAchievements` method in `DailyQuizRealtimeScreen`.
2. Define new achievement conditions based on the quiz results.
3. Create new achievement objects with appropriate IDs, names, and descriptions.

### Updating Quiz Schedule

The quiz schedule is determined by the backend, but the app needs to display the correct time:

1. Modify the `QuizTimeUtility` class in `lib/utils/quiz/time_utility.dart`.
2. Update the `getNextEventTime` method to reflect the new schedule.
3. Make sure the `DailyQuizCountdown` widget displays the updated time correctly.

## Testing

### Socket Testing

For testing socket connections:

1. Use the `testDailyQuizSocketConnection` function from `lib/utils/socket_test.dart`.
2. This will log connection status, events, and payloads to the console.
3. Make sure you're connected to the correct environment (development, staging, or production).

### Mock Data

For UI development without a live socket connection:

1. Create mock question data in the `DailyQuizBloc` for testing question rendering.
2. Simulate state transitions without actual socket events.
3. For achievement testing, manually trigger achievement unlocking events.

## Related Documentation

For more detailed information, see:

- [Complete Daily Quiz User Flow](../../../docs/daily_quiz_flow.md)
- [Socket.io Communication Protocol](../../../docs/socket_protocol.md) (if available)
- [Achievement System Integration](../../../docs/achievements.md) (if available) 