import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Bottom Navigation Bar Widget - Reusable bottom navigation component
/// This widget provides consistent navigation across the app
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;          // Currently selected tab index
  final Function(int) onTap;       // Callback when tab is tapped
  
  const AppBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // Navigation bar configuration
      type: BottomNavigationBarType.fixed, // Show all labels
      currentIndex: currentIndex,
      onTap: onTap,
      
      // Color scheme
      selectedItemColor: AppConstants.accentColor,
      unselectedItemColor: AppConstants.secondaryTextColor,
      backgroundColor: AppConstants.backgroundColor,
      
      // Visual styling
      elevation: 8,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      
      // Navigation items
      items: const <BottomNavigationBarItem>[
        // Search tab
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          activeIcon: Icon(Icons.search, size: 26),
          label: AppConstants.searchLabel,
          tooltip: 'Search for cities',
        ),
        
        // Home/Current weather tab
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          activeIcon: Icon(Icons.home, size: 26),
          label: AppConstants.homeLabel,
          tooltip: 'Current weather',
        ),
        
        // Hourly forecast tab
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          activeIcon: Icon(Icons.access_time, size: 26),
          label: AppConstants.hourlyLabel,
          tooltip: 'Hourly forecast',
        ),
        
        // Daily forecast tab
        BottomNavigationBarItem(
          icon: Icon(Icons.today),
          activeIcon: Icon(Icons.today, size: 26),
          label: AppConstants.dailyLabel,
          tooltip: 'Daily forecast',
        ),
        
        // Weekly forecast tab
        BottomNavigationBarItem(
          icon: Icon(Icons.date_range),
          activeIcon: Icon(Icons.date_range, size: 26),
          label: AppConstants.weeklyLabel,
          tooltip: 'Weekly forecast',
        ),
      ],
    );
  }
}

/// Tab Navigation Helper - Utility class for navigation logic
/// This class provides helper methods for tab navigation management
class TabNavigationHelper {
  /// Navigation tab indices
  static const int searchTab = 0;
  static const int homeTab = 1;
  static const int hourlyTab = 2;
  static const int dailyTab = 3;
  static const int weeklyTab = 4;
  
  /// Get tab title for the given index
  static String getTabTitle(int index) {
    switch (index) {
      case searchTab:
        return AppConstants.searchLabel;
      case homeTab:
        return AppConstants.homeLabel;
      case hourlyTab:
        return AppConstants.hourlyLabel;
      case dailyTab:
        return AppConstants.dailyLabel;
      case weeklyTab:
        return AppConstants.weeklyLabel;
      default:
        return 'Unknown';
    }
  }
  
  /// Check if the given tab requires weather data
  static bool requiresWeatherData(int index) {
    return index == homeTab || 
           index == hourlyTab || 
           index == dailyTab || 
           index == weeklyTab;
  }
  
  /// Check if the given tab is a forecast tab
  static bool isForecastTab(int index) {
    return index == hourlyTab || 
           index == dailyTab || 
           index == weeklyTab;
  }
}