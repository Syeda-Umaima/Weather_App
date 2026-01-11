// ============================================================
// API CONSTANTS - Weather App
// ============================================================

import 'api_constants_local.dart';

class ApiConstants {
  // GeoNames API for city search
  static const String geoNamesBaseUrl = 'http://api.geonames.org';
  static const String geoNamesUsername = ApiKeys.geoNamesUsername;
  
  // OpenWeatherMap API for weather data
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String openWeatherApiKey = ApiKeys.openWeatherApiKey;
  
  // API Configuration
  static const int maxCityResults = 10;
  static const int debounceDelayMs = 500;
  static const String units = 'metric';
  
  // Validation helpers
  static bool get hasGeoNamesCredentials => geoNamesUsername.isNotEmpty;
  static bool get hasWeatherApiKey => openWeatherApiKey.isNotEmpty;
  static bool get isConfigured => hasGeoNamesCredentials && hasWeatherApiKey;
}