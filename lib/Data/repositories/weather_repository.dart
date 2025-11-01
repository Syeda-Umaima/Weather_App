import '../models/weather_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/daily_weather_model.dart';
import '../models/weekly_weather_model.dart';
import '../models/city_model.dart';
import '../services/weather_api_service.dart';

// Business logic layer for weather operations acts as a wrapper around the WeatherApiService
// It can add caching, data validation, or other business logic
class WeatherRepository {
  static Future<WeatherModel> getCurrentWeather(CityModel city) async {
    try {
      print('🌤️ Repository: Getting current weather for ${city.displayName}');

      if (!_isValidCoordinates(city.latitude, city.longitude)) {
        throw Exception('Invalid coordinates for ${city.displayName}');
      }

      // Call the API service to get current weather
      final weather = await WeatherApiService.getCurrentWeather(
        city.latitude.toString(),
        city.longitude.toString(),
      );

      print('🌤️ Repository: Current weather retrieved successfully');

      return weather;
    } catch (e) {
      print('❌ Weather Repository Error: $e');
      throw Exception('Repository: Failed to get current weather - $e');
    }
  }

  // Gets hourly weather forecast for the specified city
  static Future<List<HourlyWeatherModel>> getHourlyForecast(
    CityModel city,
  ) async {
    try {
      print('⏰ Repository: Getting hourly forecast for ${city.displayName}');

      if (!_isValidCoordinates(city.latitude, city.longitude)) {
        throw Exception('Invalid coordinates for ${city.displayName}');
      }
      // Call the API service to get hourly forecast
      final hourlyForecast = await WeatherApiService.getHourlyForecast(
        city.latitude.toString(),
        city.longitude.toString(),
      );

      // Filter to show only next 24 hours (8 forecasts with 3-hour intervals)
      final next24Hours = hourlyForecast.take(8).toList();
      print('⏰ Repository: Found ${next24Hours.length} hourly forecasts');

      return next24Hours;
    } catch (e) {
      print('❌ Hourly Forecast Repository Error: $e');
      throw Exception('Repository: Failed to get hourly forecast - $e');
    }
  }

  // Gets daily weather forecast for the specified city
  static Future<List<DailyWeatherModel>> getDailyForecast(
    CityModel city,
  ) async {
    try {
      print('📅 Repository: Getting daily forecast for ${city.displayName}');

      if (!_isValidCoordinates(city.latitude, city.longitude)) {
        throw Exception('Invalid coordinates for ${city.displayName}');
      }

      // Call the API service to get daily forecast
      final dailyForecast = await WeatherApiService.getDailyForecast(
        city.latitude.toString(),
        city.longitude.toString(),
      );

      // Sort by date to ensure proper order
      dailyForecast.sort((a, b) => a.date.compareTo(b.date));
      print('📅 Repository: Found ${dailyForecast.length} daily forecasts');

      return dailyForecast;
    } catch (e) {
      print('❌ Daily Forecast Repository Error: $e');
      throw Exception('Repository: Failed to get daily forecast - $e');
    }
  }

  // Gets weekly weather forecast for the specified city
  static Future<WeeklyWeatherModel> getWeeklyForecast(CityModel city) async {
    try {
      print('📊 Repository: Getting weekly forecast for ${city.displayName}');

      if (!_isValidCoordinates(city.latitude, city.longitude)) {
        throw Exception('Invalid coordinates for ${city.displayName}');
      }

      // Call the API service to get weekly forecast
      final weeklyForecast = await WeatherApiService.getWeeklyForecast(
        city.latitude.toString(),
        city.longitude.toString(),
      );

      print('📊 Repository: Weekly forecast retrieved successfully');

      return weeklyForecast;
    } catch (e) {
      print('❌ Weekly Forecast Repository Error: $e');
      throw Exception('Repository: Failed to get weekly forecast - $e');
    }
  }

  // Validates if coordinates are valid (returns true if coordinates are valid, false otherwise)
  static bool _isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  // Gets weather condition icon URL from OpenWeatherMa
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  // Determines if weather condition is severe (for alerts) (returns true if severe, false otherwise)
  static bool isSevereWeather(String description) {
    final severeConditions = [
      'thunderstorm',
      'heavy rain',
      'snow',
      'blizzard',
      'tornado',
      'hurricane',
    ];

    final lowerDescription = description.toLowerCase();
    return severeConditions.any(
      (condition) => lowerDescription.contains(condition),
    );
  }
}
