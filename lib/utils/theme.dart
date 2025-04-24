import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/colors.dart';
import '../config/fonts.dart';

class AppTheme {
  static final _montserratTextTheme = GoogleFonts.montserratTextTheme();
  static final _interTextTheme = GoogleFonts.interTextTheme();

  static TextTheme _getTextTheme(bool isDark) {
    final Color textColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;

    return TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: FontConfig.displayLarge.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.5,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: FontConfig.displayMedium.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.5,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: FontConfig.displaySmall.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.25,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: FontConfig.headlineLarge.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: FontConfig.headlineMedium.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: FontConfig.headlineSmall.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: FontConfig.titleLarge.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: FontConfig.titleMedium.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: FontConfig.titleSmall.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: FontConfig.bodyLarge.sp,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: FontConfig.bodyMedium.sp,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: FontConfig.bodySmall.sp,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: FontConfig.labelLarge.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: FontConfig.labelMedium.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: FontConfig.labelSmall.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  static ThemeData lightTheme() {
    final textTheme = _getTextTheme(false);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimaryText,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightOutlineBg,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
          ),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.inter(
          color: AppColors.lightLabelText.withOpacity(0.6),
          fontSize: 16.sp,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.lightLabelText,
          fontSize: 16.sp,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        fillColor: AppColors.lightPrimaryBg,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.lightOutlineBg.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.lightOutlineBg, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final textTheme = _getTextTheme(true);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.darkPrimaryText,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimaryText,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkOutlineBg,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
          ),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.inter(
          color: AppColors.darkLabelText.withOpacity(0.6),
          fontSize: 16.sp,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.darkLabelText,
          fontSize: 16.sp,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        fillColor: AppColors.darkPrimaryBg,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.darkOutlineBg.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.darkOutlineBg, width: 1.5),
        ),
      ),
    );
  }

  // Special default theme with red and blue colors
  static ThemeData defaultTheme() {
    final textTheme = _getTextTheme(false);

    return ThemeData(
      brightness: Brightness.light, 
      primaryColor: AppColors.primary, // Red
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,        // Red
        secondary: AppColors.secondary,    // Blue
        tertiary: AppColors.accentOrange,  // Orange accent
        surface: Colors.white,
        background: Colors.white,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: textTheme,
      cardColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // Red buttons
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary, // Red text
          side: BorderSide(color: AppColors.primary), // Red border
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary, // Blue text for text buttons
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
          ),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
