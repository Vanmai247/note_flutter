import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF8B6CF3); // tím chính
  static const Color primarySoft = Color(0xFFEFE9FF); // nền tím nhạt
  static const Color bg = Color(0xFFF7F4FF);
  static const Color text = Color(0xFF2A2A2A);
  static const Color subtle = Color(0xFF9AA0A6);
  static const Color card = Colors.white;
}

ThemeData buildTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.bg,
    useMaterial3: true,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.text,
    ),
  );
}

BoxDecoration neoCard() => BoxDecoration(
  color: AppColors.card,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ],
);
