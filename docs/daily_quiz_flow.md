# Daily Quiz Feature Documentation

## Overview

The Daily Quiz is a real-time multiplayer quiz feature where users compete by answering text-based questions simultaneously. The quiz is scheduled daily at 9 AM UTC, consists of 10 questions, and rewards users with points, achievements, and premium subscription time.

## User Flow

### 1. Discovering the Daily Quiz

#### Home Screen
- Users can see a countdown to the next daily quiz on the home screen
- The countdown shows hours, minutes, and seconds until the quiz starts
- Information about the quiz theme and estimated duration is displayed

#### Daily Quiz Home Screen
- Users can access detailed information about the upcoming quiz
- Information includes quiz theme, duration, question count, and difficulty
- A "How to Play" section explains the quiz rules and point system
- Previous quiz results are shown if available

### 2. Joining the Daily Quiz

#### Waiting Room
- At 9 AM UTC, users can join the active quiz
- Users enter a virtual waiting room where they can see other participants joining
- The app connects to the socket.io server via the `/daily-quiz` namespace
- Authentication is handled automatically using the user's token

### 3. Quiz Experience

#### Question Presentation
- All participants see questions simultaneously
- A 15-second countdown timer starts for each question
- Users type their answers in a text input field
- The input field is disabled after submission or when time expires

#### Answer Processing
- Answers are matched case-insensitively against accepted answers
- Points are awarded based on:
  - Correctness: 100 base points for correct answers
  - Speed: Up to 100 additional points based on response time
  - Difficulty: Easy (1x), Medium (1.5x), Hard (2x) multipliers

#### Question Feedback
- After answering, users see if their answer was correct or incorrect
- The correct answer is displayed with an explanation
- Points earned for the question are shown
- A real-time leaderboard shows participant rankings

### 4. Quiz Completion

#### Final Results
- After all 10 questions, users see their final score
- The results screen shows:
  - Total score
  - Number of correct answers
  - User's ranking among participants
  - Daily streak information

#### Winner Announcement
- The winner is highlighted at the top of the leaderboard
- The winner receives a premium subscription reward
- All users can see who won and their score

#### Achievement Unlocking
- Users can unlock various achievements based on their performance:
  - Perfect Quiz Master: Complete a quiz with a perfect score
  - High Scorer: Score 1000+ points in a single quiz
  - Quiz Champion: Win first place with at least 3 participants
  - Quiz Enthusiast: Participate in the daily quiz

### 5. Post-Quiz Actions

#### Review Questions
- Users can review all questions from the quiz
- The review screen shows:
  - The question text
  - The user's answer
  - The correct answer
  - Explanation for each question

#### Social Sharing
- Users can share their quiz results on social media
- Share options include Twitter, Facebook, and clipboard copying
- Shared content includes score, rank, and points earned

#### Next Quiz Preview
- After completion, users can see when the next quiz will be available
- Option to set a reminder is available
- Users are encouraged to return for the next day's quiz

## Technical Components

### Screens
1. `DailyQuizHomeScreen`: Entry point with quiz information and countdown
2. `DailyQuizRealtimeScreen`: Real-time quiz experience with socket communication
3. `QuizReviewScreen`: Post-quiz review of all questions and answers

### Widgets
1. `DailyQuizCountdown`: Displays time until next quiz
2. `QuizCountdownTimer`: Shows countdown during active questions
3. `ParticipantList`: Displays real-time participant rankings
4. `QuizShareCard`: UI for sharing quiz results on social media

### BLoCs
1. `DailyQuizBloc`: Manages the real-time quiz state and socket communication
2. `AchievementBloc`: Handles unlocking and tracking achievements

### Services
1. `DailyQuizSocket`: Manages socket.io communication for the quiz
2. `AuthTokenService`: Handles authentication for socket connections

## Achievement System Integration

The Daily Quiz integrates with the app's achievement system, allowing users to earn various achievements:

1. **Performance-based Achievements**:
   - Perfect Quiz Master (Gold): Complete a quiz with a perfect score
   - High Scorer (Silver): Score 1000+ points in a single quiz

2. **Participation Achievements**:
   - Quiz Enthusiast (Bronze): Participate in the daily quiz
   - Quiz Champion (Platinum): Win first place with at least 3 participants

3. **Streak Achievements**:
   - Streak Master: Maintain a consecutive daily quiz streak

## Social Sharing Feature

Users can share their quiz results with friends through:

1. Direct social media sharing (Twitter, Facebook)
2. Text copying to clipboard for manual sharing
3. Customized sharing card with visual presentation of results

## Premium Integration

The Daily Quiz serves as a gateway to premium features:

1. The winner of each daily quiz receives a free 1-day premium subscription
2. Premium users get additional insights and statistics
3. Premium subscription banners are displayed for non-premium users 