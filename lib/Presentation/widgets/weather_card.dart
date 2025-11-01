import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/neumorphic_card.dart';

class WeatherCard extends StatelessWidget {
  final String title;
  final String temperature;
  final String? subtitle;
  final String? additionalInfo;
  final Widget? icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool useGradient;
  final List<Color>? gradientColors;
  
  const WeatherCard({
    Key? key,
    required this.title,
    required this.temperature,
    this.subtitle,
    this.additionalInfo,
    this.icon,
    this.backgroundColor,
    this.onTap,
    this.useGradient = false,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useGradient && gradientColors != null) {
      return GradientNeumorphicCard(
        gradientColors: gradientColors!,
        onTap: onTap,
        child: _buildContent(context, true),
      );
    }
    
    return NeumorphicCard(
      onTap: onTap,
      child: _buildContent(context, false),
    );
  }

  Widget _buildContent(BuildContext context, bool isGradient) {
    final textColor = isGradient 
        ? Colors.white 
        : AppConstants.getTextColor(context);
    final secondaryColor = isGradient 
        ? Colors.white.withOpacity(0.8) 
        : AppConstants.getSecondaryTextColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: secondaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) 
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isGradient 
                      ? Colors.white.withOpacity(0.2)
                      : AppConstants.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: icon!,
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Temperature
        Text(
          temperature,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Subtitle
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // Additional info
        if (additionalInfo != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isGradient 
                  ? Colors.white.withOpacity(0.2)
                  : AppConstants.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              additionalInfo!,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class CompactWeatherCard extends StatelessWidget {
  final String time;
  final String temperature;
  final String? description;
  final Widget? icon;
  final bool isSelected;
  
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
      width: 80, // Fixed width to prevent overflow
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppConstants.getPrimaryColor(context)
            : AppConstants.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time
          Text(
            time,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white
                  : AppConstants.getSecondaryTextColor(context),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Icon
          if (icon != null) ...[
            SizedBox(
              width: 24,
              height: 24,
              child: icon!,
            ),
            const SizedBox(height: 4),
          ],
          // Temperature
          Text(
            temperature,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white
                  : AppConstants.getTextColor(context),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Description
          if (description != null) ...[
            const SizedBox(height: 2),
            Text(
              description!,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white.withOpacity(0.9)
                    : AppConstants.getSecondaryTextColor(context),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}