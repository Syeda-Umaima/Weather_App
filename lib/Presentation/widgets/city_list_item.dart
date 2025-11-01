import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../core/utils/country_helper.dart';
import '../../core/constants/app_constants.dart';

/// City List Item Widget - Reusable widget for displaying city information
/// This widget shows city details in a ListTile format for city selection
class CityListItem extends StatelessWidget {
  final CityModel city;              // The city to display
  final VoidCallback onTap;          // Callback when city is tapped
  final bool isLoading;              // Whether this item is in loading state
  
  const CityListItem({
    Key? key,
    required this.city,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Handle tap events
      onTap: isLoading ? null : onTap,
      
      // Leading icon with country flag emoji
      leading: CircleAvatar(
        backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
        child: Text(
          CountryHelper.countryCodeToEmoji(city.countryCode),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      
      // City name and country
      title: Text(
        city.displayName,
        style: AppConstants.bodyTextStyle.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Coordinates information
      subtitle: Text(
        city.coordinatesString,
        style: const TextStyle(
          color: AppConstants.secondaryTextColor,
          fontSize: 12,
        ),
      ),
      
      // Trailing widget - loading indicator or arrow
      trailing: isLoading 
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppConstants.accentColor,
            ),
          )
        : const Icon(
            Icons.arrow_forward_ios,
            color: AppConstants.secondaryTextColor,
            size: 16,
          ),
      
      // Visual styling
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: isLoading 
        ? AppConstants.primaryColor.withOpacity(0.1) 
        : null,
      
      // Rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}