import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTypography {
  AdminTypography._();

  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  );
}
