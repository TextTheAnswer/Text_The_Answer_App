import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/widgets/custom_3D_button.dart';
import '../../config/colors.dart';
import '../../router/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
     {
      'title': 'Text The Answer',
      'description': 'Text the answer in the fastest time and spell correctly to win.',
      'image': 'assets/images/onboard3.png',
    },
    {
      'title': 'Test Your Knowledge',
      'description': 'Challenge yourself with fun trivia across various categories and expand your knowledge daily.',
      'image': 'assets/images/onboard1.png',
    },
    {
      'title': 'Compete with Friends',
      'description': 'Create private lobbies, invite friends, and see who can answer questions correctly in the fastest time.',
      'image': 'assets/images/onboard2.png',
    },
   
    {
      'title': 'Daily Challenges',
      'description': 'Join our daily themed quizzes and climb the global leaderboards with your spelling and speed skills.',
      'image': 'assets/images/onboard3.png',
    },
    {
      'title': 'Study & Improve',
      'description': 'Create study materials, generate practice questions, and track your improvement over time.',
      'image': 'assets/images/onboard3.png',
    },
    {
      'title': 'Join Our Community',
      'description': 'Become part of a growing community of trivia enthusiasts and knowledge seekers from around the world.',
      'image': 'assets/images/onboard3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 1.0],
            colors: [AppColors.primary, AppColors.primary],
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/auth_bg_pattern.png'),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App logo or branding
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'TEXT THE ANSWER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              
              // -- Pageview
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return FadeIn(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              onboardingData[index]['image']!,
                              height: 240,
                            ),
                            const SizedBox(height: 30),
                            Text(
                              onboardingData[index]['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              onboardingData[index]['description']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Page indicators
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // -- Next and Skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Custom3DButton(
                          semanticsLabel:
                              _currentPage == onboardingData.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                          backgroundColor: AppColors.buttonPrimary,
                          onPressed: () {
                            if (_currentPage == onboardingData.length - 1) {
                              // Navigator.pushNamedAndRemoveUntil(
                              //   context,
                              //   Routes.signup,
                              //   (route) => false,
                              // );
                              context.go(AppRoutePath.signup);
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == onboardingData.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                              if (_currentPage != onboardingData.length - 1)
                                const SizedBox(width: 8),
                              if (_currentPage != onboardingData.length - 1)
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_currentPage < onboardingData.length - 1)
                      const SizedBox(width: 16),
                    if (_currentPage < onboardingData.length - 1)
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Custom3DButton(
                          backgroundColor: AppColors.buttonSecondary,
                          semanticsLabel: 'Skip',
                          onPressed: () {
                            _pageController.animateToPage(
                              onboardingData.length - 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -- I already have an account
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Custom3DButton(
                  semanticsLabel: 'I already have an account',
                  backgroundColor: AppColors.buttonTertiary,
                  onPressed: () {
                    // Navigator.pushNamedAndRemoveUntil(
                    //   context,
                    //   Routes.login,
                    //   (route) => false,
                    // );
                    context.go(AppRoutePath.login);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.login_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'I ALREADY HAVE AN ACCOUNT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
