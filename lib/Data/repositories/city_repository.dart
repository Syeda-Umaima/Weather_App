import '../models/city_model.dart';
import '../services/city_api_service.dart';

// Business logic layer for city operations acts as a wrapper around the CityApiService
// It can add caching, data validation, or other business logic
class CityRepository {
  
  // This method: Validates the input query, Calls the API service to fetch cities
  static Future<List<CityModel>> searchCities(String query) async {
    try {
      // Validate input
      if (query.trim().isEmpty) {
        return []; // Return empty list for empty queries
      }
      
      // Minimum query length check
      if (query.trim().length < 2) {
        return []; // Return empty list for very short queries
      }
      
      print('🏙️ Repository: Searching for cities with query: "$query"');
      
      // Call the API service to get cities
      final cities = await CityApiService.searchCities(query.trim());
      
      // Remove duplicates based on name and country code
      final uniqueCities = <CityModel>[];
      final seenCities = <String>{};
      
      // Uses a set to track seen city names with country codes like London_UK, London_CA
      for (final city in cities) {
        final cityKey = '${city.name}_${city.countryCode}';
        if (!seenCities.contains(cityKey)) {
          seenCities.add(cityKey);
          uniqueCities.add(city);
        }
      }
      
      print('🏙️ Repository: Found ${uniqueCities.length} unique cities');
      
      return uniqueCities;
      
    } catch (e) {
      print('❌ City Repository Error: $e');
      throw Exception('Repository: Failed to search cities - $e');
    }
  }
  
  // Validates if a city has valid coordinates 
  static bool isValidCity(CityModel city) {
    // Check if coordinates are within valid ranges i.e. Latitude: -90 to +90 & Longitude: -180 to +180
    return city.latitude >= -90 && 
           city.latitude <= 90 && 
           city.longitude >= -180 && 
           city.longitude <= 180 &&
           city.name.isNotEmpty;
  }
  
  // Methods for a formatted string suitable for display in UI
  static String getDisplayString(CityModel city) {
    return '${city.name}, ${city.countryName}';
  }
  
  static String getDetailedDisplayString(CityModel city) {
    return '${getDisplayString(city)}\n${city.coordinatesString}';
  }
}