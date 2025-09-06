import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color.fromARGB(255, 209, 160, 0);
  static const darkPrimary = Color.fromARGB(255, 26, 26, 26);
  static const accent = Color.fromARGB(255, 255, 187, 0);
  static const backgroundLight = Color.fromARGB(255, 235, 235, 235);
  static const backgroundDark = Color.fromARGB(255, 44, 44, 44);
  static const textLight = Colors.black54;
  static const textDark = Colors.white;
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.primary,//de azul a negro
    onPrimaryContainer: AppColors.darkPrimary,//de negro a azul
    onPrimaryFixed: Colors.white,//blanco a azul
    secondary: AppColors.accent,
    surface: AppColors.backgroundLight,
    onSurface: AppColors.textLight,
    onSurfaceVariant: AppColors.primary,
  ),
  scaffoldBackgroundColor: AppColors.backgroundLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  //textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
   textTheme: GoogleFonts.poppinsTextTheme(),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.darkPrimary,
    onPrimaryContainer: AppColors.primary,
    onPrimaryFixed: AppColors.primary,//blanco a azul
    secondary: AppColors.accent,
    surface: AppColors.backgroundDark,
    onSurface: AppColors.textDark,
    onSurfaceVariant: AppColors.textDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
);
