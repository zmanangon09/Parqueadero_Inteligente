import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primary = Color(0xFF0F766E);
  static const _secondary = Color(0xFF14B8A6);
  static const _cta = Color(0xFF0369A1);
  static const _background = Color(0xFFF0FDFA);
  static const _textDark = Color(0xFF134E4A);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: _primary,
          onPrimary: Colors.white,
          secondary: _secondary,
          onSecondary: Colors.white,
          tertiary: _cta,
          onTertiary: Colors.white,
          surface: _background,
          onSurface: _textDark,
          error: Color(0xFFDC2626),
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: _background,
        textTheme: GoogleFonts.workSansTextTheme().copyWith(
          displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: _textDark),
          headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: _textDark),
          headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: _textDark),
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: _textDark),
          titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: _textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _cta,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Color.fromARGB(102, 3, 105, 161),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
            animationDuration: const Duration(milliseconds: 200),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _primary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _secondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x4D0F766E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: GoogleFonts.workSans(color: _textDark),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: _primary),
      );
}
