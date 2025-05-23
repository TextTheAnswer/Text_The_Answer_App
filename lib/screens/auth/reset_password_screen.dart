import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/config/colors.dart' show AppColors;
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/services/api_service.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/custom_3d_button.dart';
import 'package:text_the_answer/widgets/custom_bottom_button_with_divider.dart';
import 'package:text_the_answer/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;
  final _apiService = ApiService();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle reset password submission
  Future<void> _resetPassword() async {
    // Basic validation
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter and confirm your new password';
      });
      return;
    }

    // Password match validation
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    // Password strength validation
    if (_passwordController.text.length < 8) {
      setState(() {
        _errorMessage = 'Password must be at least 8 characters long';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // final response = await _apiService.resetPassword(
      //   email: widget.email,
      //   resetToken: widget.resetToken,
      //   newPassword: _passwordController.text,
      //   confirmPassword: _confirmPasswordController.text,
      // );

      // Show success message and navigate to login screen
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // content: Text(response['message'] ?? 'Password reset successful'),
          content: Text('Password reset successful'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to login screen
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   Routes.login,
      //   (route) => false, // Clear all routes in the stack
      // );
      context.go(AppRoutePath.login);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 24),

              // -- Header
              Text(
                'Reset Password 🔐',
                style: FontUtility.montserratBold(
                  fontSize: 28,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create a new secure password for your account',
                style: FontUtility.interRegular(
                  fontSize: 15,
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 40),

              // -- New Password Field
              CustomTextField(
                controller: _passwordController,
                hintText: 'Create a new password',
                obscureText: _obscurePassword,
                iconColor: AppColors.secondary,
                toggleObscureText: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },

                darkMode: true,
                errorText: _errorMessage,
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 16),

              // -- Confirm Password Field
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm new password',
                obscureText: _obscureConfirmPassword,
                iconColor: AppColors.secondary,
                toggleObscureText: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                darkMode: true,
              ),

              const SizedBox(height: 20),

              // -- Remember Me
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
                      fillColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.secondary;
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
                ],
              ),
              SizedBox(height: 48),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomButtonWithDivider(
        child: Custom3DButton(
          backgroundColor: AppColors.buttonPrimary,
          borderRadius: BorderRadius.circular(100.r),
          onPressed: _isLoading ? null : _resetPassword,
          child: Text(
            'RESET PASSWORD',
            style: FontUtility.montserratBold(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
