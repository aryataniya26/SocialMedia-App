import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.textLight,
        fontSize: 14,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../core/constants/app_colors.dart';
//
// class AppTheme {
//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
//     primaryColor: AppColors.primary,
//     scaffoldBackgroundColor: AppColors.background,
//
//     // AppBar Theme
//     appBarTheme: AppBarTheme(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: false,
//       iconTheme: const IconThemeData(color: AppColors.textPrimary),
//       titleTextStyle: GoogleFonts.poppins(
//         color: AppColors.textPrimary,
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//
//     // Text Theme
//     textTheme: TextTheme(
//       displayLarge: GoogleFonts.poppins(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: AppColors.textPrimary,
//       ),
//       displayMedium: GoogleFonts.poppins(
//         fontSize: 24,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//       ),
//       bodyLarge: GoogleFonts.poppins(
//         fontSize: 16,
//         color: AppColors.textPrimary,
//       ),
//       bodyMedium: GoogleFonts.poppins(
//         fontSize: 14,
//         color: AppColors.textSecondary,
//       ),
//       labelLarge: GoogleFonts.poppins(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     ),
//
//     // Input Decoration Theme
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: AppColors.cardBackground,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.border),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.border),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.primary, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.error),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       hintStyle: GoogleFonts.poppins(
//         color: AppColors.textLight,
//         fontSize: 14,
//       ),
//     ),
//
//     // Elevated Button Theme
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         textStyle: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
//
//     // Bottom Navigation Bar Theme
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Colors.white,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: AppColors.textLight,
//       type: BottomNavigationBarType.fixed,
//       elevation: 8,
//     ),
//   );
// }