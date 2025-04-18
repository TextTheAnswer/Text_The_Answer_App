import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/utils/font_utility.dart';

enum CustomButtonType {
  primary, // Blue in auth screens
  secondary, // Red background
  outline, // Outlined buttons like social login
}

enum CustomButtonSize {
  small, // For smaller actions
  medium, // Default
  large, // Prominent actions
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonType buttonType;
  final CustomButtonSize buttonSize;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final bool darkMode;
  final TextStyle? textStyle;
  final Color? bgColor;
  final Color? textColor;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonType = CustomButtonType.primary,
    this.buttonSize = CustomButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.padding,
    this.darkMode = true, // Default to dark mode
    this.textStyle,
    this.bgColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine button sizing
    double height;
    switch (buttonSize) {
      case CustomButtonSize.small:
        height = 40.h;
        break;
      case CustomButtonSize.medium:
        height = 48.h;
        break;
      case CustomButtonSize.large:
        height = 54.h;
        break;
    }

    // Determine button padding
    EdgeInsetsGeometry buttonPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: buttonSize == CustomButtonSize.small ? 16.w : 24.w,
          vertical: buttonSize == CustomButtonSize.small ? 8.h : 12.h,
        );

    // Determine button styles based on type
    Color backgroundColor;
    Color foregroundTextColor;
    Color buttonBorderColor;
    BoxBorder? border;

    switch (buttonType) {
      case CustomButtonType.primary:
        backgroundColor = bgColor ?? Colors.blue;
        foregroundTextColor = textColor ?? Colors.white;
        buttonBorderColor = borderColor ?? Colors.transparent;
        border =
            borderColor != null
                ? Border.all(color: buttonBorderColor, width: 1)
                : null;
        break;
      case CustomButtonType.secondary:
        backgroundColor = bgColor ?? AppColors.primary;
        foregroundTextColor = textColor ?? Colors.white;
        buttonBorderColor = borderColor ?? Colors.transparent;
        border =
            borderColor != null
                ? Border.all(color: buttonBorderColor, width: 1)
                : null;
        break;
      case CustomButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundTextColor =
            textColor ?? (darkMode ? Colors.white : AppColors.darkGray);
        buttonBorderColor =
            borderColor ?? (darkMode ? Colors.white : AppColors.darkGray);
        border = Border.all(color: buttonBorderColor, width: 1);
        break;
    }

    // Determine text style
    TextStyle buttonTextStyle =
        textStyle ??
        FontUtility.montserratBold(
          fontSize: 16,
          color: foregroundTextColor,
          letterSpacing: 1.2,
        );

    // Create the button widget
    Widget buttonWidget;

    if (buttonType == CustomButtonType.outline) {
      // Create outlined button
      buttonWidget = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: buttonPadding,
          side: BorderSide(color: buttonBorderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _buildButtonContent(buttonTextStyle, foregroundTextColor),
      );
    } else {
      // Create elevated button
      buttonWidget = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundTextColor,
          padding: buttonPadding,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
        child: _buildButtonContent(buttonTextStyle, foregroundTextColor),
      );
    }

    // Wrap with Container for consistent sizing and shadow
    return Container(
      width: fullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: border,
        boxShadow:
            buttonType != CustomButtonType.outline
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
                : null,
      ),
      child: buttonWidget,
    );
  }

  Widget _buildButtonContent(TextStyle textStyle, Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        height: 20.h,
        width: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          valueColor: AlwaysStoppedAnimation<Color>(
            buttonType == CustomButtonType.outline
                ? (textColor ?? (darkMode ? Colors.white : AppColors.darkGray))
                : foregroundColor,
          ),
        ),
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp),
          SizedBox(width: 8.w),
          Text(text, style: textStyle),
        ],
      );
    } else {
      return Text(text, style: textStyle);
    }
  }
}
