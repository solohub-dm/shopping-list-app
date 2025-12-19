import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/app_state.dart' as models;
import 'package:shopping_list_app/utils/app_constants.dart';

class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.grey[50],
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.borderMedium, width: AppSizes.borderWidthThin),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.borderMedium, width: AppSizes.borderWidthThin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: AppSizes.borderWidthMedium),
        ),
        contentPadding: AppSizes.inputPadding,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: AppSizes.buttonPadding,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          textStyle: const TextStyle(
            fontSize: AppSizes.buttonFontSize,
            fontWeight: AppSizes.buttonFontWeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: AppSizes.buttonPadding,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          side: BorderSide(
            color: AppColors.borderMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
          ),
          foregroundColor: AppColors.textPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: AppSizes.buttonPadding,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
          ),
          foregroundColor: AppColors.primary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          side: BorderSide(
            color: AppColors.borderLight,
            width: AppSizes.borderWidthMedium,
          ),
        ),
        color: AppColors.bgPrimary,
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      cardColor: const Color(0xFF1F2937),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.darkBorderMedium, width: AppSizes.borderWidthThin),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
          borderSide: BorderSide(color: AppColors.darkBorderMedium, width: AppSizes.borderWidthThin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: AppSizes.borderWidthMedium),
        ),
        contentPadding: AppSizes.inputPadding,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: AppSizes.buttonPadding,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          textStyle: const TextStyle(
            fontSize: AppSizes.buttonFontSize,
            fontWeight: AppSizes.buttonFontWeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: AppSizes.buttonPadding,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          side: BorderSide(
            color: AppColors.darkBorderMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
          ),
          foregroundColor: AppColors.darkTextPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: AppSizes.buttonPadding,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
          ),
          foregroundColor: AppColors.primaryLight,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          side: BorderSide(
            color: AppColors.darkBorderLight,
            width: AppSizes.borderWidthMedium,
          ),
        ),
        color: AppColors.darkBgSecondary,
      ),
    );
  }

  static ThemeMode themeModeFromAppState(models.AppThemeMode mode) {
    switch (mode) {
      case models.AppThemeMode.light:
        return ThemeMode.light;
      case models.AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

