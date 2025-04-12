import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;
  final bool isLoading;
  final bool darkMode;

  const SocialLoginButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.darkMode = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = darkMode ? Colors.white : AppColors.darkGray;
    final Color borderColor = darkMode ? Colors.white : AppColors.darkGray.withOpacity(0.3);
    
    return Container(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ) 
            : Icon(
                icon,
                size: 24,
                color: textColor,
              ),
        label: Text(
          text,
          style: FontUtility.interMedium(
            fontSize: 16,
            color: textColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
} 