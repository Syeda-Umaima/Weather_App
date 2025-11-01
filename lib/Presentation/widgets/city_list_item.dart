import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../core/utils/country_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/neumorphic_card.dart';

class CityListItem extends StatelessWidget {
  final CityModel city;
  final VoidCallback onTap;
  final bool isLoading;
  
  const CityListItem({
    Key? key,
    required this.city,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicCard(
        onTap: isLoading ? null : onTap,
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppConstants.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                CountryHelper.countryCodeToEmoji(city.countryCode),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.displayName,
                    style: AppConstants.getBodyStyle(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    city.coordinatesString,
                    style: TextStyle(
                      color: AppConstants.getSecondaryTextColor(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppConstants.getPrimaryColor(context),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppConstants.getSecondaryTextColor(context),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
