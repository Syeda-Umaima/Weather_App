import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const AppBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.getCardColor(context),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.shade300,
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
          BoxShadow(
            color: isDark 
                ? Colors.white.withOpacity(0.05)
                : Colors.white,
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.search, AppConstants.searchLabel),
              _buildNavItem(context, 1, Icons.home_rounded, AppConstants.homeLabel),
              _buildNavItem(context, 2, Icons.access_time_rounded, AppConstants.hourlyLabel),
              _buildNavItem(context, 3, Icons.today_rounded, AppConstants.dailyLabel),
              _buildNavItem(context, 4, Icons.date_range_rounded, AppConstants.weeklyLabel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final primaryColor = AppConstants.getPrimaryColor(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? primaryColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? primaryColor
                    : AppConstants.getSecondaryTextColor(context),
                size: isSelected ? 28 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? primaryColor
                      : AppConstants.getSecondaryTextColor(context),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabNavigationHelper {
  static const int searchTab = 0;
  static const int homeTab = 1;
  static const int hourlyTab = 2;
  static const int dailyTab = 3;
  static const int weeklyTab = 4;
  
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
  
  static bool requiresWeatherData(int index) {
    return index == homeTab || 
           index == hourlyTab || 
           index == dailyTab || 
           index == weeklyTab;
  }
  
  static bool isForecastTab(int index) {
    return index == hourlyTab || 
           index == dailyTab || 
           index == weeklyTab;
  }
}
