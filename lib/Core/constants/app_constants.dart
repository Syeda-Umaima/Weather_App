import 'package:flutter/material.dart';

class AppConstants {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFE8F4FF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF5B9EE1);
  static const Color lightAccent = Color(0xFFFF9F43);
  static const Color lightText = Color(0xFF2C3E50);
  static const Color lightSecondaryText = Color(0xFF7F8C8D);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1F3A);
  static const Color darkCardBackground = Color(0xFF252B48);
  static const Color darkPrimary = Color(0xFF5B9EE1);
  static const Color darkAccent = Color(0xFFFFB84D);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFB8BFD4);
  
  // Common Colors
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF39C12);
  
  // Gradient Colors
  static const List<Color> sunnyGradient = [Color(0xFFFFD93D), Color(0xFFFF9F43)];
  static const List<Color> cloudyGradient = [Color(0xFF5B9EE1), Color(0xFF4A90E2)];
  static const List<Color> rainyGradient = [Color(0xFF667EEA), Color(0xFF764BA2)];
  static const List<Color> nightGradient = [Color(0xFF1A1F3A), Color(0xFF2E3856)];
  
  // App Strings
  static const String appTitle = 'Weather App';
  static const String pickLocationTitle = 'Pick Location';
  static const String pickLocationSubtitle = 'Find the area or city you want to check the weather for';
  static const String searchHint = 'Search your City';
  static const String errorCityFetch = 'Failed to fetch cities. Please try again.';
  static const String errorWeatherFetch = 'Failed to fetch Weather. Please try again.';
  
  // Navigation Labels
  static const String searchLabel = 'Search';
  static const String homeLabel = 'Home';
  static const String hourlyLabel = 'Hourly';
  static const String dailyLabel = 'Daily';
  static const String weeklyLabel = 'Weekly';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Spacing
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  
  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 16.0;
  static const double largeRadius = 24.0;
  
  // Text Styles - Light Theme
  static TextStyle lightTitleTextStyle = const TextStyle(
    color: lightText,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle lightSubtitleTextStyle = const TextStyle(
    color: lightSecondaryText,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle lightBodyTextStyle = const TextStyle(
    color: lightText,
    fontSize: 14,
  );
  
  // Text Styles - Dark Theme
  static TextStyle darkTitleTextStyle = const TextStyle(
    color: darkText,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle darkSubtitleTextStyle = const TextStyle(
    color: darkSecondaryText,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle darkBodyTextStyle = const TextStyle(
    color: darkText,
    fontSize: 14,
  );
  
  // Get theme-aware colors
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightBackground 
        : darkBackground;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightCardBackground 
        : darkCardBackground;
  }
  
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightPrimary 
        : darkPrimary;
  }
  
  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightAccent 
        : darkAccent;
  }
  
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightText 
        : darkText;
  }
  
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightSecondaryText 
        : darkSecondaryText;
  }
  
  static TextStyle getTitleStyle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightTitleTextStyle 
        : darkTitleTextStyle;
  }
  
  static TextStyle getSubtitleStyle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightSubtitleTextStyle 
        : darkSubtitleTextStyle;
  }
  
  static TextStyle getBodyStyle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? lightBodyTextStyle 
        : darkBodyTextStyle;
  }
}
