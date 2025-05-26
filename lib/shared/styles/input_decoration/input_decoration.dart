import 'package:flutter/material.dart';

class CustomInputDecoration {
  /// Can not initialize
  CustomInputDecoration._();

  /// Decoration properties for a textfied with no borde and transparent fill
  static InputDecoration get borderlessField => InputDecoration(
    fillColor: Colors.transparent,

    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,

    hintStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
  );

  static TextStyle get borderlessFieldTextStyle =>
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);
}
