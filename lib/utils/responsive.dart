import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Responsive utility class
class Responsive {
  final BuildContext context;
  final double width;
  final double height;

  Responsive._(this.context, this.width, this.height);

  factory Responsive.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Responsive._(
      context,
      mediaQuery.size.width,
      mediaQuery.size.height,
    );
  }

  /// Check if screen is mobile
  bool get isMobile => width < Breakpoints.mobile;

  /// Check if screen is tablet
  bool get isTablet =>
      width >= Breakpoints.mobile && width < Breakpoints.desktop;

  /// Check if screen is desktop
  bool get isDesktop => width >= Breakpoints.desktop;

  /// Get responsive padding
  EdgeInsets get padding {
    if (isMobile) {
      return const EdgeInsets.all(16);
    } else if (isTablet) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Get responsive horizontal padding
  double get horizontalPadding {
    if (isMobile) {
      return 16;
    } else if (isTablet) {
      return 20;
    } else {
      return 24;
    }
  }

  /// Get responsive spacing
  double get spacing {
    if (isMobile) {
      return 16;
    } else if (isTablet) {
      return 20;
    } else {
      return 24;
    }
  }

  /// Get responsive grid columns
  int getGridColumns(int defaultColumns) {
    if (isMobile) {
      return 1;
    } else if (isTablet) {
      return defaultColumns > 2 ? 2 : defaultColumns;
    } else {
      return defaultColumns;
    }
  }

  /// Get responsive font size multiplier
  double get fontSizeMultiplier {
    if (isMobile) {
      return 0.9;
    } else if (isTablet) {
      return 0.95;
    } else {
      return 1.0;
    }
  }
}

/// Extension for easy access to Responsive
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive.of(this);
}

