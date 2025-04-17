import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart' show AppColors;
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/services/api_service.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/custom_button.dart';
import 'package:text_the_answer/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;
  
  const ResetPasswordScreen({
    Key? key, 
    required this.email,
    required this.resetToken,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
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
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
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
      final response = await _apiService.resetPassword(
        email: widget.email,
        resetToken: widget.resetToken,
        newPassword: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      
      // Show success message and navigate to login screen
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Password reset successful'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false, // Clear all routes in the stack
      );
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
      backgroundColor: AppColors.primaryRed,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                
                // New Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'New Password',
                  obscureText: _obscurePassword,
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
                
                const SizedBox(height: 40),
                
                // Reset Password Button
                CustomButton(
                  text: 'RESET PASSWORD',
                  buttonType: CustomButtonType.primary,
                  buttonSize: CustomButtonSize.large,
                  isLoading: _isLoading,
                  onPressed: _resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 