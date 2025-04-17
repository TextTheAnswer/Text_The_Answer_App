import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/config/colors.dart' show AppColors;
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/screens/auth/forgot_password_screen.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/custom_button.dart';
import 'package:text_the_answer/widgets/custom_text_field.dart';
import 'package:text_the_answer/widgets/social_login_button.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const LoginScreen({required this.toggleTheme, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pushReplacementNamed(
                context,
                Routes.home,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    AppColors.primaryRed,
                    AppColors.primaryRed,
                  ],
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/auth_bg_pattern.png'),
                  fit: BoxFit.cover,
                  opacity: 0.05,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                           Image.asset('assets/images/splash_page.png',
                    height: 60,
                    width: 60,
                    ),
                    SizedBox(width: 20,),
                    // Header
                    Text(
                      'Hello there 👋',
                      style: FontUtility.montserratBold(
                        fontSize: 28,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                      ]
                    ),
                   
                    const SizedBox(height: 12),
                    // Subheader
                    Text(
                      'Welcome back! Please sign in to continue',
                      style: FontUtility.interRegular(
                        fontSize: 15,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 35),
                    
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      darkMode: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      toggleObscureText: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      darkMode: true,
                    ),
                    const SizedBox(height: 20),
                    
                    // Remember Me & Forgot Password
                    _buildRememberMeAndForgotPassword(),
                    const SizedBox(height: 30),
                    
                    // Sign In Button
                    _buildSignInButton(context),
                    const SizedBox(height: 24),
                    
                    // Divider with "or" text
                    _buildDividerWithText('or'),
                    const SizedBox(height: 24),
                    
                    // Social Login Buttons
                    _buildSocialLoginButtons(),
                    const SizedBox(height: 30),
                    
                    // Sign Up Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.signup,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                side: BorderSide(color: Colors.white),
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue;
                  }
                  return Colors.transparent;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Remember me',
              style: FontUtility.interRegular(
                fontSize: 15,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.forgotPassword,
            );
          },
          child: Text(
            'Forgot Password?',
            style: FontUtility.interMedium(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return CustomButton(
          text: 'SIGN IN',
          buttonType: CustomButtonType.primary,
          buttonSize: CustomButtonSize.large,
          isLoading: state is AuthLoading,
          onPressed: () {
            // Basic validation
            if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter both email and password')),
              );
              return;
            }
            
            // Email format validation
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(_emailController.text)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter a valid email address')),
              );
              return;
            }
            
            // Trigger sign in event
            context.read<AuthBloc>().add(
                  SignInEvent(
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                  ),
                );
          },
        );
      }
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.white.withOpacity(0.6),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: FontUtility.interRegular(
              fontSize: 16,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.white.withOpacity(0.6),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        SocialLoginButton(
          text: 'Continue with Google',
          onPressed: () {
            // Implement Google Sign-In
          },
          icon: Icons.g_mobiledata,
        ),
        const SizedBox(height: 16),
        SocialLoginButton(
          text: 'Continue with Apple',
          onPressed: () {
            // Implement Apple Sign-In
          },
          icon: Icons.apple,
        ),
      ],
    );
  }
}