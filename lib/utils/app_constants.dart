import 'package:flutter/material.dart';

class AppSizes {
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;

  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 12.0;
  static const double paddingLG = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;

  static const double inputHeight = 44.0;
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  static const EdgeInsets inputPaddingWithIcon = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  static const double inputIconSize = 18.0;
  static const double inputFontSize = 14.0;
  static const double inputBorderRadius = borderRadiusSmall;

  static const double buttonHeight = 44.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const double buttonFontSize = 16.0;
  static const double buttonBorderRadius = borderRadiusSmall;
  static const FontWeight buttonFontWeight = FontWeight.w500;

  static const double dropdownHeight = 44.0;
  static const EdgeInsets dropdownPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const double dropdownFontSize = 14.0;
  static const double dropdownIconSize = 20.0;
  static const double dropdownBorderRadius = borderRadiusSmall;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 18.0;
  static const double iconSizeLarge = 20.0;
  static const double iconSizeXL = 24.0;

  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;

  static const EdgeInsets cardPadding = EdgeInsets.all(paddingXXL);
  static const EdgeInsets cardPaddingMedium = EdgeInsets.symmetric(horizontal: paddingXL, vertical: paddingXL);
  static const double cardBorderRadius = borderRadiusMedium;
  static const double cardBorderWidth = borderWidthMedium;

  static const double headerHeight = 64.0;

  static const double modalMaxWidth = 500.0;
}

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryBg = Color(0xFFDBEAFE);

  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF15803D);
  static const Color successBg = Color(0xFFD1FAE5);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color errorBg = Color(0xFFFEE2E2);

  static const Color warning = Color(0xFFEA580C);
  static const Color warningLight = Color(0xFFF97316);
  static const Color warningBg = Color(0xFFFED7AA);

  static const Color secondary = Color(0xFF9333EA);
  static const Color secondaryBg = Color(0xFFE9D5FF);

  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF9FAFB);
  static const Color bgTertiary = Color(0xFFF3F4F6);

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);

  static const Color darkBgPrimary = Color(0xFF111827);
  static const Color darkBgSecondary = Color(0xFF1F2937);
  static const Color darkBgTertiary = Color(0xFF374151);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextTertiary = Color(0xFF9CA3AF);

  static const Color darkBorderLight = Color(0xFF374151);
  static const Color darkBorderMedium = Color(0xFF4B5563);
  static const Color darkBorderDark = Color(0xFF6B7280);

  static const Color modalOverlay = Color(0x8A000000);

  static const Color shadow = Color(0x1A000000);
}

class AppColorScheme {
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
  }

  static Color getTextTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextTertiary
        : AppColors.textTertiary;
  }

  static Color getBgPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBgPrimary
        : AppColors.bgPrimary;
  }

  static Color getBgSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBgSecondary
        : AppColors.bgSecondary;
  }

  static Color getBgTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBgTertiary
        : AppColors.bgTertiary;
  }

  static Color getBorderLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBorderLight
        : AppColors.borderLight;
  }

  static Color getBorderMedium(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBorderMedium
        : AppColors.borderMedium;
  }

  static Color getBorderDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBorderDark
        : AppColors.borderDark;
  }
}

