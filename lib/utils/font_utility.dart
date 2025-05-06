import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../config/fonts.dart';

/// Utility class for managing fonts with Google Fonts and local fallbacks
class FontUtility {
  // Configure Google Fonts to use local fallbacks
  static void configureGoogleFonts() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  // Montserrat font utility methods
  static TextStyle montserrat({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      // fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  // Pre-defined Montserrat styles
  static TextStyle montserratBold({
    double fontSize = 16,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return montserrat(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle montserratSemiBold({
    double fontSize = 16,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return montserrat(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle montserratMedium({
    double fontSize = 16,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return montserrat(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle montserratRegular({
    double fontSize = 16,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return montserrat(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  // Inter font utility methods
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      // fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  // Pre-defined Inter styles
  static TextStyle interBold({
    double fontSize = 16,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return inter(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle interSemiBold({
    double fontSize = 16,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle interMedium({
    double fontSize = 16,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle interRegular({
    double fontSize = 16,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    double? height,
  }) {
    return inter(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      height: height,
    );
  }
}
