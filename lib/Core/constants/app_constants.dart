import 'package:flutter/material.dart';

class AppConstants {
  // App Colors
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.amberAccent; 
  static const Color backgroundColor = Colors.black;
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Colors.white70;
  static const Color errorColor = Colors.red;
  
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
  
  // Text Styles
  static const TextStyle titleTextStyle = TextStyle(
    color: textColor,
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle subtitleTextStyle = TextStyle(
    color: secondaryTextColor,
    fontSize: 18,
  );
  
  static const TextStyle bodyTextStyle = TextStyle(
    color: textColor,
    fontSize: 16,
  );
}