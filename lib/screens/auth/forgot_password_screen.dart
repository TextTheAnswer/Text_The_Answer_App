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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _apiService = ApiService();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Handle the reset password request
  Future<void> _requestPasswordReset() async {
    // Basic validation
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // final response = await _apiService.requestPasswordReset(
      //   _emailController.text.trim(),
      // );

      // Navigate to OTP verification screen
      if (!mounted) return;

      // Navigator.pushNamed(
      //   context,
      //   Routes.otpVerification,
      //   arguments: {'email': _emailController.text.trim()},
      // );

      context.push(
        AppRoutePath.otpVerification(email: _emailController.text.trim()),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Successfully sent OTP')));
      // ).showSnackBar(SnackBar(content: Text(response['message'])));
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
      bottomNavigationBar: CustomBottomButtonWithDivider(
        child: Custom3DButton(
          backgroundColor: AppColors.buttonPrimary,
          borderRadius: BorderRadius.circular(100.r),
          onPressed: _isLoading ? null : _requestPasswordReset,
          child: Text(
            'Continue',
            style: FontUtility.montserratBold(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forgot Password? 🔑',
                  style: FontUtility.montserratBold(
                    fontSize: 28,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your email address to receive a password reset OTP',
                  style: FontUtility.interRegular(
                    fontSize: 15,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  darkMode: true,

                  errorText: _errorMessage,
                  onChanged: (_) => setState(() => _errorMessage = null),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
