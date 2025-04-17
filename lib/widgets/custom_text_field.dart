// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Icon? prefixIcon;
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
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.toggleObscureText,
    this.darkMode = true,
    this.errorText,
    this.autoFocus = false,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = darkMode ? AppColors.white : AppColors.darkGray;
    final Color hintColor =
        darkMode
            ? Colors.white.withOpacity(0.7)
            : AppColors.darkGray.withOpacity(0.6);
    final Color iconColor =
        darkMode
            ? Colors.white.withOpacity(0.9)
            : AppColors.darkGray.withOpacity(0.7);

    return TextField(
      controller: controller,
      style: FontUtility.interRegular(fontSize: 20, color: textColor),
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
        contentPadding: contentPadding ?? EdgeInsets.symmetric(vertical: 8),
        labelText: hintText,
        labelStyle: FontUtility.interRegular(fontSize: 18, color: textColor),
        hintStyle: FontUtility.interRegular(fontSize: 18, color: hintColor),
        errorText: errorText,
        errorStyle: FontUtility.interRegular(
          fontSize: 12,
          color: AppColors.error,
        ),
        prefixIcon: prefixIcon,
        suffixIcon:
            toggleObscureText != null
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                  onPressed: toggleObscureText,
                )
                : null,
        filled: true,
        fillColor: Colors.transparent,
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
