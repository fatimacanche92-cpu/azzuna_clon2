import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Definiendo la Paleta de Colores
class AppColors {
  static const Color roseQuartz = Color(0xFFF9CBD6);
  static const Color blush = Color(0xFFF2AFBC);
  static const Color redWine = Color(0xFF9E182B);
  static const Color oatMilk = Color(0xFFF2E0D2);

  // Colores originales para el modo de reversión
  static const Color originalPurple = Color(0xFF340A6B);
  static const Color originalBackground = Color(0xFFF3E5F5);
}

// Helper para crear MaterialColor
MaterialColor _createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

// 2. ThemeData para la paleta "Azzuna"
final ThemeData azzunaTheme = ThemeData(
  primarySwatch: _createMaterialColor(AppColors.redWine),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: AppColors.oatMilk,

  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.redWine,
    primary: AppColors.redWine,
    secondary: AppColors.blush,
    background: AppColors.oatMilk,
    surface: AppColors.roseQuartz,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.black,
    onSurface: AppColors.redWine,
    brightness: Brightness.light,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.oatMilk,
    foregroundColor: AppColors.redWine,
    elevation: 0,
    titleTextStyle: GoogleFonts.poppins(
      color: AppColors.redWine,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: const IconThemeData(color: AppColors.redWine),
  ),

  cardTheme: CardThemeData(
    color: Colors.white, // Un poco más limpio que roseQuartz para las tarjetas
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.redWine,
    foregroundColor: Colors.white,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.redWine,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.redWine,
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
    ),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.redWine,
    unselectedItemColor: Colors.grey[600],
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    unselectedLabelStyle: GoogleFonts.poppins(),
  ),

  textTheme: GoogleFonts.poppinsTextTheme(),

  iconTheme: const IconThemeData(color: AppColors.redWine),
);

// 3. ThemeData para el tema "Original"
final ThemeData originalTheme = ThemeData(
  primarySwatch: _createMaterialColor(AppColors.originalPurple),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: AppColors.originalBackground,

  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.originalPurple,
    brightness: Brightness.light,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: GoogleFonts.poppins(
      color: AppColors.originalPurple,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: const IconThemeData(color: AppColors.originalPurple),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.originalPurple,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.originalPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.originalPurple,
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
    ),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.purple,
    unselectedItemColor: Colors.grey,
  ),

  textTheme: GoogleFonts.poppinsTextTheme(),
);

// 4. State Notifier para gestionar el tema
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(azzunaTheme); // Inicia con el tema por defecto

  // Flag para el modo de reversión
  bool _revertColors = false;

  void toggleColorPalette(String word) {
    if (word == 'PALETA_AZZUNA') {
      _revertColors = false;
      state = azzunaTheme;
    } else if (word == 'COLOR_ORIGINAL') {
      _revertColors = true;
      state = originalTheme;
    }
  }

  ThemeData getCurrentTheme() {
    return _revertColors ? originalTheme : azzunaTheme;
  }
}

// 5. Provider para acceder al ThemeNotifier
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

// Variable global para el flag (según lo solicitado, aunque no es la mejor práctica)
// Es mejor manejarlo dentro del notifier como ya se hizo.
// Si se necesita un acceso global simple, se podría usar un provider.
// final revertColorsProvider = StateProvider<bool>((ref) => false);
