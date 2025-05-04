import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/config/colors.dart' show AppColors;
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/custom_3D_button.dart';
import 'package:text_the_answer/widgets/custom_bottom_button_with_divider.dart';
import 'package:text_the_answer/widgets/custom_text_field.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      bottomNavigationBar: CustomBottomButtonWithDivider(
        child: _buildSignUpButton(context),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // Navigator.pushReplacementNamed(context, Routes.profileCreate);
              context.go(AppRoutePath.profileCreate);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [AppColors.primary, AppColors.primary],
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/auth_bg_pattern.png'),
                  fit: BoxFit.cover,
                  opacity: 0.05,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/splash_page.png',
                          height: 60,
                          width: 60,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            'Create an account 🔑',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Subheader
                    Text(
                      'Please enter your username, email address and password.',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Username Field
                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'Username',
                      keyboardType: TextInputType.text,
                      darkMode: true,
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      toggleObscureText: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      darkMode: true,
                    ),
                    const SizedBox(height: 20),

                    // Remember Me Checkbox
                    _buildRememberMeCheckbox(),
                    const SizedBox(height: 30),

                    // Divider with "or" text
                    _buildDividerWithText('or'),
                    const SizedBox(height: 24),

                    // Social Login Buttons
                    _buildSocialLoginButtons(),
                    const SizedBox(height: 30),

                    // Sign In Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, Routes.login);
                          context.go(AppRoutePath.login);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign in',
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

  Widget _buildRememberMeCheckbox() {
    return Row(
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
          style: TextStyle(color: AppColors.white, fontSize: 15),
        ),
        Spacer(),
        TextButton(
          onPressed: () {
            // Navigator.of(context).pushNamed(Routes.forgotPassword);
            context.push(AppRoutePath.forgotPassword);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isLoading = state is AuthLoading;

        //TODO: Refactor to make it more readable and clean @danielkiing3
        return Custom3DButton(
          backgroundColor: AppColors.buttonPrimary,
          borderRadius: BorderRadius.circular(100.r),
          onPressed:
              isLoading
                  ? null
                  : () {
                    context.read<AuthBloc>().add(
                      SignUpEvent(
                        email: _emailController.text,
                        password: _passwordController.text,
                        name: _usernameController.text,
                      ),
                    );
                  },
          child:
              isLoading
                  ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                  : Text(
                    'SIGN UP',
                    style: FontUtility.montserratBold(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.white.withOpacity(0.6), thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.white.withOpacity(0.6), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // -- Google Sign in Button
        Custom3DButton(
          backgroundColor: AppColors.buttonSecondary,
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata, color: Colors.white),
              const SizedBox(width: 8),

              Text(
                'Continue with Google',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // -- Apple Sign In Button
        Custom3DButton(
          backgroundColor: AppColors.buttonSecondary,
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.apple, color: Colors.white),
              const SizedBox(width: 8),

              Text(
                'Continue with Apple',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
