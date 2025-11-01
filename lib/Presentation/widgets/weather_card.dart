import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Weather Card Widget - Reusable card for displaying weather information
/// This widget provides a consistent card layout for various weather data displays
class WeatherCard extends StatelessWidget {
  final String title;              // Card title (e.g., "Current Weather")
  final String temperature;        // Main temperature display
  final String? subtitle;          // Optional subtitle (e.g., weather description)
  final String? additionalInfo;    // Optional additional information
  final Widget? icon;              // Optional weather icon
  final Color? backgroundColor;    // Optional background color
  final VoidCallback? onTap;       // Optional tap callback
  
  const WeatherCard({
    Key? key,
    required this.title,
    required this.temperature,
    this.subtitle,
    this.additionalInfo,
    this.icon,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? AppConstants.primaryColor.withOpacity(0.1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with title and optional icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    title,
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  
                  // Optional icon
                  if (icon != null) icon!,
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Main temperature display
              Text(
                temperature,
                style: const TextStyle(
                  color: AppConstants.textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Optional subtitle (weather description)
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppConstants.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
              
              // Optional additional information
              if (additionalInfo != null) ...[
                const SizedBox(height: 8),
                Text(
                  additionalInfo!,
                  style: const TextStyle(
                    color: AppConstants.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact Weather Card - Smaller version for list items
/// This widget provides a compact card layout for hourly/daily weather displays
class CompactWeatherCard extends StatelessWidget {
  final String time;               // Time or day display
  final String temperature;        // Temperature display
  final String? description;       // Optional weather description
  final Widget? icon;              // Optional weather icon
  final bool isSelected;           // Whether this card is selected
  
  const CompactWeatherCard({
    Key? key,
    required this.time,
    required this.temperature,
    this.description,
    this.icon,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected 
          ? AppConstants.accentColor.withOpacity(0.2)
          : AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isSelected 
          ? Border.all(color: AppConstants.accentColor, width: 1)
          : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time or day
          Text(
            time,
            style: TextStyle(
              color: isSelected 
                ? AppConstants.accentColor 
                : AppConstants.secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Optional weather icon
          if (icon != null) ...[
            SizedBox(
              width: 24,
              height: 24,
              child: icon!,
            ),
            const SizedBox(height: 8),
          ],
          
          // Temperature
          Text(
            temperature,
            style: TextStyle(
              color: isSelected 
                ? AppConstants.textColor 
                : AppConstants.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Optional description
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: const TextStyle(
                color: AppConstants.secondaryTextColor,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}