import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final isDark = await _storage.read(key: 'dark_mode');
    _isDarkMode = isDark == 'true';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.write(key: 'dark_mode', value: _isDarkMode.toString());
    notifyListeners();
  }

  // ── Shared text theme builder ───────────────────────────────────────────
  // Montserrat = body/sans-serif  (letterSpacing 0)
  // Oxanium    = display/headings
  // Playfair Display = serif slots
  // Source Code Pro  = monospace slots
  TextTheme _buildTextTheme({required bool dark}) {
    final baseColor = dark ? const Color(0xFFFAFAFA) : const Color(0xFF18181B);
    final mutedColor = dark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);

    return GoogleFonts.montserratTextTheme(
      TextTheme(
        // ── Display / Headline → Oxanium ──────────────────────────────────
        displayLarge: GoogleFonts.oxanium(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: baseColor,
          letterSpacing: 0,
        ),
        displayMedium: GoogleFonts.oxanium(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: baseColor,
          letterSpacing: 0,
        ),
        displaySmall: GoogleFonts.oxanium(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: baseColor,
          letterSpacing: 0,
        ),
        headlineLarge: GoogleFonts.oxanium(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: baseColor,
          letterSpacing: 0,
        ),
        headlineMedium: GoogleFonts.oxanium(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: baseColor,
          letterSpacing: 0,
        ),
        headlineSmall: GoogleFonts.oxanium(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: baseColor,
          letterSpacing: 0,
        ),
        titleLarge: GoogleFonts.oxanium(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: baseColor,
          letterSpacing: 0,
        ),
        // ── Title / Body / Label → Montserrat ─────────────────────────────
        titleMedium: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: baseColor,
          letterSpacing: 0,
        ),
        titleSmall: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: baseColor,
          letterSpacing: 0,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: baseColor,
          letterSpacing: 0,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: mutedColor,
          letterSpacing: 0,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: mutedColor,
          letterSpacing: 0,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: baseColor,
          letterSpacing: 0,
        ),
        labelMedium: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: baseColor,
          letterSpacing: 0,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: mutedColor,
          letterSpacing: 0,
        ),
      ),
    );
  }

  // ── Light Theme ─────────────────────────────────────────────────────────
  ThemeData get lightTheme {
    final textTheme = _buildTextTheme(dark: false);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF18181B),
        secondary: Color(0xFF71717A),
        surface: Colors.white,
        error: Color(0xFFEF4444),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: const Color(0xFF18181B),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.oxanium(
          color: const Color(0xFF18181B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE4E4E7), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF18181B),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.montserrat(fontSize: 14, letterSpacing: 0),
        hintStyle: GoogleFonts.montserrat(fontSize: 14, letterSpacing: 0),
      ),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────────────────────
  ThemeData get darkTheme {
    final textTheme = _buildTextTheme(dark: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF09090B),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFAFAFA),
        secondary: Color(0xFFA1A1AA),
        surface: Color(0xFF18181B),
        error: Color(0xFFEF4444),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF09090B),
        foregroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.oxanium(
          color: const Color(0xFFFAFAFA),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF27272A), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFAFAFA),
          foregroundColor: const Color(0xFF09090B),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.montserrat(fontSize: 14, letterSpacing: 0),
        hintStyle: GoogleFonts.montserrat(fontSize: 14, letterSpacing: 0),
      ),
    );
  }
}
