import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/utils/font_utility.dart';

enum CustomButtonType {
  primary,  // Blue in auth screens
  secondary, // Red background
  outline,   // Outlined buttons like social login
}

enum CustomButtonSize {
  small,   // For smaller actions
  medium,  // Default
  large,   // Prominent actions
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

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonType = CustomButtonType.primary,
    this.buttonSize = CustomButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.padding,
    this.darkMode = true,  // Default to dark mode
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button sizing
    double height;
    switch (buttonSize) {
      case CustomButtonSize.small:
        height = 40;
        break;
      case CustomButtonSize.medium:
        height = 48;
        break;
      case CustomButtonSize.large:
        height = 54;
        break;
    }

    // Determine button padding
    EdgeInsetsGeometry buttonPadding = padding ?? 
        EdgeInsets.symmetric(
          horizontal: buttonSize == CustomButtonSize.small ? 16 : 24,
          vertical: buttonSize == CustomButtonSize.small ? 8 : 12,
        );

    // Determine button styles based on type
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    BoxBorder? border;

    switch (buttonType) {
      case CustomButtonType.primary:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        border = null;
        break;
      case CustomButtonType.secondary:
        backgroundColor = AppColors.primaryRed;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        border = null;
        break;
      case CustomButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = darkMode ? Colors.white : AppColors.darkGray;
        borderColor = darkMode ? Colors.white : AppColors.darkGray;
        border = Border.all(color: borderColor, width: 1);
        break;
    }

    // Determine text style
    TextStyle buttonTextStyle = textStyle ?? FontUtility.montserratBold(
      fontSize: 16,
      color: textColor,
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
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildButtonContent(buttonTextStyle),
      );
    } else {
      // Create elevated button
      buttonWidget = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: buttonPadding,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildButtonContent(buttonTextStyle),
      );
    }

    // Wrap with Container for consistent sizing and shadow
    return Container(
      width: fullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: border,
        boxShadow: buttonType != CustomButtonType.outline
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: buttonWidget,
    );
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            buttonType == CustomButtonType.outline
                ? (darkMode ? Colors.white : AppColors.darkGray)
                : Colors.white,
          ),
        ),
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    } else {
      return Text(text, style: textStyle);
    }
  }
} 