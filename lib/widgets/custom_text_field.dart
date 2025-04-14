import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final VoidCallback? toggleObscureText;
  final bool darkMode;
  final String? errorText;
  final bool autoFocus;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final bool readOnly;
  final int? maxLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.toggleObscureText,
    this.darkMode = true, // Default to light mode
    this.errorText,
    this.autoFocus = false,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.readOnly = false,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = darkMode ? AppColors.white : AppColors.darkGray;
    final Color hintColor = darkMode 
        ? Colors.white.withOpacity(0.7) 
        : AppColors.darkGray.withOpacity(0.6);
    final Color iconColor = darkMode 
        ? Colors.white.withOpacity(0.9) 
        : AppColors.darkGray.withOpacity(0.7);
    final Color fillColor = darkMode 
        ? Colors.white.withOpacity(0.1)
        : AppColors.lightGray.withOpacity(0.1);
    final Color borderColor = darkMode 
        ? Colors.white.withOpacity(0.3)
        : AppColors.darkGray.withOpacity(0.2);
    final Color focusedBorderColor = darkMode 
        ? Colors.white
        : AppColors.primaryRed;

    return TextField(
      controller: controller,
      style: FontUtility.interRegular(
        fontSize: 16,
        color: textColor,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      autofocus: autoFocus,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        contentPadding: contentPadding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintText: hintText,
        hintStyle: FontUtility.interRegular(
          fontSize: 16,
          color: hintColor,
        ),
        errorText: errorText,
        errorStyle: FontUtility.interRegular(
          fontSize: 12,
          color: Colors.red,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: iconColor,
        ),
        suffixIcon: toggleObscureText != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: iconColor,
                ),
                onPressed: toggleObscureText,
              )
            : null,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
} 