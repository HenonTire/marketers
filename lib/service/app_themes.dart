import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  static TextStyle poppins(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
