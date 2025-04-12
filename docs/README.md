# Text the Answer App

A stunning trivia game app built with Flutter, BLoC, and custom authentication.

## Features
- Custom API authentication with Google and Apple SSO options
- Daily quiz and multiplayer game modes
- Real-time leaderboards via Socket.IO
- Modern UI with consistent red-gradient background design
- Custom widgets for reusability
- Responsive design patterns

## Design System
- **Color Scheme:**
  - Primary: Red (#D32F2F)
  - Accent: Blue (for buttons)
  - Text: White (on red backgrounds)
  - Input fields: Semi-transparent white with rounded corners
  - Consistent styling across auth and onboarding screens

- **UI Components:**
  - Rectangular inputs with rounded corners (12px radius)
  - Consistent button styling (blue for primary actions)
  - White iconography and text on red backgrounds
  - Subtle background pattern for visual interest

## Folder Structure
- `blocs/`: State management with BLoC
- `config/`: Constants for colors, text, and API
- `models/`: Data models
- `services/`: API integration
- `screens/`: UI screens
- `widgets/`: Custom reusable widgets

## Setup
1. Install Flutter and dependencies: `flutter pub get`
2. Configure API endpoint in `.env` file
3. Run the app: `flutter run`

## Authentication Flow
The app now uses a custom authentication API endpoint:
- **Register:** POST to `/api/auth/register`
- **Login:** POST to `/api/auth/login`
- **Apple Auth:** Integration prepared for future use

## Color Scheme
- Primary: Red (#D32F2F)
- Accent: Orange (#F4A261)
- Background: Dark Gray (#1D3557)
- Highlights: Light Gray (#A8DADC)


Making Edits
Adding a New Screen:
Create a new file in lib/screens/ (e.g., new_screen.dart).
Define a new StatelessWidget or StatefulWidget:
dart

Collapse

Wrap

Copy
import 'package:flutter/material.dart';

class NewScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const NewScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Screen',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Navigate to the new screen from an existing screen (e.g., HomeScreen):
dart

Collapse

Wrap

Copy
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewScreen(toggleTheme: toggleTheme),
      ),
    );
  },
  child: const Text('Go to New Screen'),
),
Modifying the Theme:
Edit lib/utils/theme.dart to adjust colors, fonts, or styles:
dart

Collapse

Wrap

Copy
static ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryRed,
    scaffoldBackgroundColor: AppColors.white,
    textTheme: TextTheme(
      headlineLarge: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blue, // Change color
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: AppColors.darkGray,
      ),
    ),
    // Add more customizations
  );
}
Adding a New BLoC:
Create a new folder in lib/blocs/ (e.g., new_feature/).
Add new_feature_bloc.dart, new_feature_event.dart, and new_feature_state.dart:
dart

Collapse

Wrap

Copy
// new_feature_event.dart
abstract class NewFeatureEvent {}

class FetchData extends NewFeatureEvent {}

// new_feature_state.dart
abstract class NewFeatureState {}

class NewFeatureInitial extends NewFeatureState {}

class NewFeatureLoading extends NewFeatureState {}

class NewFeatureLoaded extends NewFeatureState {
  final String data;

  NewFeatureLoaded({required this.data});
}

class NewFeatureError extends NewFeatureState {
  final String message;

  NewFeatureError({required this.message});
}

// new_feature_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'new_feature_event.dart';
import 'new_feature_state.dart';

class NewFeatureBloc extends Bloc<NewFeatureEvent, NewFeatureState> {
  NewFeatureBloc() : super(NewFeatureInitial()) {
    on<FetchData>((event, emit) async {
      emit(NewFeatureLoading());
      try {
        // Simulate fetching data
        await Future.delayed(const Duration(seconds: 1));
        emit(NewFeatureLoaded(data: "Sample Data"));
      } catch (e) {
        emit(NewFeatureError(message: e.toString()));
      }
    });
  }
}
Provide the BLoC in main.dart:
dart

Collapse

Wrap

Copy
providers: [
  BlocProvider(create: (_) => AuthBloc()),
  BlocProvider(create: (_) => NewFeatureBloc()),
],
Use the BLoC in a screen:
dart

Collapse

Wrap

Copy
BlocBuilder<NewFeatureBloc, NewFeatureState>(
  builder: (context, state) {
    if (state is NewFeatureLoading) {
      return const CircularProgressIndicator();
    } else if (state is NewFeatureLoaded) {
      return Text(state.data);
    } else if (state is NewFeatureError) {
      return Text(state.message);
    }
    return const Text('Press to load data');
  },
),
ElevatedButton(
  onPressed: () {
    context.read<NewFeatureBloc>().add(FetchData());
  },
  child: const Text('Load Data'),
),
Adding a New API Call:
Update lib/services/api_service.dart:
dart

Collapse

Wrap

Copy
Future<Map<String, dynamic>> newApiCall() async {
  final response = await http.get(
    Uri.parse('$baseUrl/new-endpoint'),
    headers: {'Authorization': 'Bearer YOUR_TOKEN'},
  );
  return jsonDecode(response.body);
}
Call the API in a BLoC or screen:
dart

Collapse

Wrap

Copy
final response = await ApiService().newApiCall();
Adding a New Widget:
Create a new file in lib/widgets/ (e.g., new_widget.dart):
dart

Collapse

Wrap

Copy
import 'package:flutter/material.dart';

class NewWidget extends StatelessWidget {
  final String text;

  const NewWidget({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.blue,
      child: Text(text),
    );
  }
}
Use the widget in a screen:
dart

Collapse

Wrap

Copy
const NewWidget(text: 'Hello, World!'),
Testing the App
Test on Android Emulator (Optional):
Open Android Studio, set up an emulator, and run:
text

Collapse

Wrap

Copy
flutter run
This allows you to test the UI and functionality on Android while setting up iOS testing.
Test on iOS:
Since you're on Windows, you can't run an iOS simulator directly. Use one of these methods:
Cloud-Based Simulator:
Sign up for BrowserStack.
Build the app:
text

Collapse

Wrap

Copy
flutter build ios --release
Upload the generated .ipa file (from build/ios/) to BrowserStack for testing.
Physical iOS Device:
Build the app on Windows:
text

Collapse

Wrap

Copy
flutter build ios --release
Transfer the project to a macOS machine.
On the macOS machine, run:
text

Collapse

Wrap

Copy
flutter run -d <device-id>
MacinCloud:
Rent a macOS environment from MacinCloud.
Open the project in VS Code or Xcode and run the app on a simulator.
Unit Testing:
Create a test file in the test/ directory (e.g., auth_bloc_test.dart):
dart

Collapse

Wrap

Copy
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:text_the_answer/blocs/auth/auth_bloc.dart';
import 'package:text_the_answer/services/supabase_service.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockSupabaseService mockSupabaseService;

    setUp(() {
      mockSupabaseService = MockSupabaseService();
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });
  });
}
Run tests:
text

Collapse

Wrap

Copy
flutter test
Widget Testing:
Create a widget test file in test/ (e.g., login_screen_test.dart):
dart

Collapse

Wrap

Copy
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_the_answer/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen displays email field', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(toggleTheme: () {}),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
  });
}
Run widget tests:
text

Collapse

Wrap

Copy
flutter test
Debugging:
Use VS Code's debugging tools:
Open a file (e.g., login_screen.dart).
Set breakpoints by clicking in the gutter next to the line numbers.
Press F5 to start debugging.
Use print statements or the debugPrint function to log information:
dart

Collapse

Wrap

Copy
debugPrint('User email: ${_emailController.text}');
Deploying to iOS
Build for iOS:
On a macOS machine (or MacinCloud), run:
text

Collapse

Wrap

Copy
flutter build ios --release
Open ios/Runner.xcworkspace in Xcode.
Sign the app with your Apple Developer account.
Test on TestFlight:
In Xcode, archive the app and upload it to TestFlight for beta testing.
Submit to App Store:
Follow Apple's guidelines to submit the app via Xcode.