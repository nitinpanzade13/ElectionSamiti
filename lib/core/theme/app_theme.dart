import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors ───
  static const Color primaryDark = Color(0xFF0F0C29);
  static const Color primaryMid = Color(0xFF302B63);
  static const Color primaryLight = Color(0xFF24243E);
  static const Color accentSaffron = Color(0xFFFF9933);
  static const Color accentGreen = Color(0xFF00C853);
  static const Color accentWhite = Color(0xFFF5F5F5);
  static const Color cardDark = Color(0xFF1E1B3A);
  static const Color cardBorder = Color(0xFF3D3867);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0AEC5);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color successGreen = Color(0xFF69F0AE);

  // ─── Gradients ───
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryMid, primaryLight],
  );

  static const LinearGradient saffronGradient = LinearGradient(
    colors: [Color(0xFFFF9933), Color(0xFFFF6F00)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
  );

  // ─── Text Styles ───
  static TextStyle get headingLarge => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get headingMedium => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get headingSmall => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.8,
      );

  static TextStyle get labelText => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  // ─── Input Decoration ───
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(
        color: textSecondary,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(
        color: textSecondary.withAlpha(100),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: accentSaffron, size: 22),
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentSaffron, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  // ─── Elevated Button Style ───
  static ButtonStyle primaryButton({Gradient? gradient}) {
    return ElevatedButton.styleFrom(
      backgroundColor: accentSaffron,
      foregroundColor: Colors.white,
      elevation: 6,
      shadowColor: accentSaffron.withAlpha(100),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: buttonText,
    );
  }

  // ─── Card Decoration ───
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ─── Glass Card Decoration ───
  static BoxDecoration get glassCard => BoxDecoration(
        color: primaryMid.withAlpha(140),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      );
}
