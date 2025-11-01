class ApiConstants {
  // GeoNames API for city search
  static const String geoNamesBaseUrl = 'http://api.geonames.org';
  static const String geoNamesUsername = 'SyedaUmaima';
  
  // OpenWeatherMap API for weather data
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String openWeatherApiKey = '6eac9eb85ae633256d13e1666508ba47';
  
  // API Configuration
  static const int maxCityResults = 10;
  static const int debounceDelayMs = 500; // For debouncing search input (to avoid excessive API calls during typing)
  static const String units = 'metric'; // For Celsius temperature
}