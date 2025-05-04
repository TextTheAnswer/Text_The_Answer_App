// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/config/colors.dart' show AppColors;
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/services/api_service.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/custom_3d_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({super.key, required this.email});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  final _apiService = ApiService();

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Get the complete OTP code
  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // Handle OTP verification
  Future<void> _verifyOTP() async {
    // Basic validation
    if (_otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // final response = await _apiService.verifyPasswordResetOTP(
      //   widget.email,
      //   _otpCode,
      // );

      // Navigate to reset password screen
      if (!mounted) return;

      // Navigator.pushNamed(
      //   context,
      //   Routes.resetPassword,
      //   arguments: {
      //     'email': widget.email,
      //     // 'resetToken': response['resetToken'],
      //     'resetToken': 'dsghirwerpewofjmweorwe',
      //   },
      // );

      context.push(
        Uri(
          path: AppRoutePath.resetPassword,
          queryParameters: {
            'email': widget.email,
            // 'resetToken': response['resetToken'],
            'resetToken': 'dsghirwerpewofjmweorwe',
          },
        ).toString(),
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

  // Handle input changes in OTP fields
  void _onChanged(String value, int index) {
    if (value.length == 1) {
      // Move to next field if not the last field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field filled, unfocus
        _focusNodes[index].unfocus();
        // Optionally auto-verify when all fields are filled
        _verifyOTP();
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
                  'You\'ve got a mail 📩',
                  style: FontUtility.montserratBold(
                    fontSize: 28,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We have sent a verification code to ${widget.email}. Check your mail and enter the code below',
                  style: FontUtility.interRegular(
                    fontSize: 15,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => _buildOTPField(index)),
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      maxLines: 2,
                      style: FontUtility.interRegular(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Resend Code
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Implement resend logic
                      // Navigator.pushReplacementNamed(
                      //   context,
                      //   Routes.forgotPassword,
                      // );

                      context.go(AppRoutePath.forgotPassword);
                    },
                    child: Text(
                      'Didn\'t receive the code? Resend',
                      style: FontUtility.interMedium(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Verify Button
                Custom3DButton(
                  backgroundColor: AppColors.buttonPrimary,
                  borderRadius: BorderRadius.circular(100.r),
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: Text(
                    'VERIFY',
                    style: FontUtility.montserratBold(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return _OTPField(
      controller: _otpControllers[index],
      focusNode: _focusNodes[index],
      onChanged: (value) => _onChanged(value, index),
    );
  }
}

/// Custom widget for individual 5OTP input field
class _OTPField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OTPField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OTPField> createState() => _OTPFieldState();
}

class _OTPFieldState extends State<_OTPField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focusNode.hasFocus;

    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused ? Colors.blue : Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          style: FontUtility.interBold(fontSize: 20, color: Colors.white),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
