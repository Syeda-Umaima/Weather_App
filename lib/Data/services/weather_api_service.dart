import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/daily_weather_model.dart';
import '../models/weekly_weather_model.dart';
import '../../core/constants/api_constants.dart';

// Handles all weather-related API calls, communicates with OpenWeatherMap API to get weather data
class WeatherApiService {
  static Future<WeatherModel> getCurrentWeather(String latitude, String longitude) async {
    try {
      // Construct the API URL for current weather
      final url = Uri.parse(
        '${ApiConstants.openWeatherBaseUrl}/weather?lat=$latitude&lon=$longitude&units=${ApiConstants.units}&appid=${ApiConstants.openWeatherApiKey}',
      );
      
      print('🌤️ Getting current weather for: $latitude, $longitude'); 
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Current weather data received'); 
        
        // Convert JSON response to WeatherModel
        return WeatherModel.fromJson(data);
        
      } else {
        print('❌ Weather API Error: ${response.statusCode}');
        throw Exception('Failed to load weather data. Status code: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Weather API Exception: $e');
      throw Exception('Failed to fetch weather data: $e');
    }
  }
  
  // Gets 5 days forecast with 3-hour intervals
  static Future<List<HourlyWeatherModel>> getHourlyForecast(String latitude, String longitude) async {
    try {
      // Construct the API URL for 5-day forecast ( with 3-hour intervals)
      final url = Uri.parse(
        '${ApiConstants.openWeatherBaseUrl}/forecast?lat=$latitude&lon=$longitude&units=${ApiConstants.units}&appid=${ApiConstants.openWeatherApiKey}', //Endpoint /forecast for 5-day forecast
      );
      
      print('⏰ Getting hourly forecast for: $latitude, $longitude'); 
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['list'] == null) {
          print('⚠️ No forecast data found in response');
          return [];
        }
        
        // Extract the list of forecasts
        List<dynamic> forecastList = data['list'];
        print('✅ Found ${forecastList.length} hourly forecasts');
        
        // Convert each JSON object (3 hour interval) to HourlyWeatherModel
        return forecastList
            .map<HourlyWeatherModel>((forecastJson) => HourlyWeatherModel.fromJson(forecastJson))
            .toList();
            
      } else {
        print('❌ Hourly Forecast API Error: ${response.statusCode}');
        throw Exception('Failed to load hourly forecast. Status code: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Hourly Forecast API Exception: $e');
      throw Exception('Failed to fetch hourly forecast: $e');
    }
  }
  
  // Gets daily forecasts from hourly data (workaround since free API doesn't have daily endpoint)
  
  static Future<List<DailyWeatherModel>> getDailyForecast(String latitude, String longitude) async {
    try {
      print('📅 Getting daily forecast for: $latitude, $longitude'); 
      
      final hourlyForecasts = await getHourlyForecast(latitude, longitude);
      
      // Group hourly forecasts by date to create daily forecasts by creating dictionary
      Map<String, List<HourlyWeatherModel>> groupedByDay = {};
      
      for (var hourlyForecast in hourlyForecasts) {
        String dateKey = '${hourlyForecast.dateTime.year}-${hourlyForecast.dateTime.month}-${hourlyForecast.dateTime.day}'; 
        
        if (!groupedByDay.containsKey(dateKey)) {
          groupedByDay[dateKey] = [];
        }
        groupedByDay[dateKey]!.add(hourlyForecast);
      }
      
      // Create daily forecasts from grouped data
      List<DailyWeatherModel> dailyForecasts = [];
      
      groupedByDay.forEach((dateKey, hourlyList) {
        if (hourlyList.isNotEmpty) {
          double minTemp = double.parse(hourlyList.first.temperature);
          double maxTemp = double.parse(hourlyList.first.temperature);
          int totalHumidity = 0;
          double totalWindSpeed = 0;
          
          for (var hourly in hourlyList) {
            double temp = double.parse(hourly.temperature);
            if (temp < minTemp) minTemp = temp;
            if (temp > maxTemp) maxTemp = temp;
            totalHumidity += hourly.humidity;
            totalWindSpeed += hourly.windSpeed;
          }
          
          DailyWeatherModel dailyForecast = DailyWeatherModel(
            date: hourlyList.first.dateTime,
            maxTemperature: maxTemp.toStringAsFixed(1),
            minTemperature: minTemp.toStringAsFixed(1),
            description: hourlyList.first.description,
            icon: hourlyList.first.icon,
            humidity: (totalHumidity / hourlyList.length).round(),
            windSpeed: totalWindSpeed / hourlyList.length,
            chanceOfRain: hourlyList.first.chanceOfRain,
            uvIndex: 5.0,  
            sunrise: '06:00',
            sunset: '18:00',
          );
          
          dailyForecasts.add(dailyForecast);
        }
      });
      
      print('✅ Created ${dailyForecasts.length} daily forecasts'); 
      return dailyForecasts;
      
    } catch (e) {
      print('❌ Daily Forecast Exception: $e');
      throw Exception('Failed to fetch daily forecast: $e');
    }
  }
  
  // Gets weekly weather forecast (7 days) by wrapping daily forecasts
  static Future<WeeklyWeatherModel> getWeeklyForecast(String latitude, String longitude) async {
    try {
      print('📊 Getting weekly forecast for: $latitude, $longitude'); 
      
      final dailyForecasts = await getDailyForecast(latitude, longitude);
      
      // Create weekly forecast model
      final weeklyForecast = WeeklyWeatherModel(
        dailyForecasts: dailyForecasts,
        locationName: 'Selected Location',
        lastUpdated: DateTime.now(),
      );
      
      print('✅ Weekly forecast created successfully'); 
      return weeklyForecast;
      
    } catch (e) {
      print('❌ Weekly Forecast Exception: $e');
      throw Exception('Failed to fetch weekly forecast: $e');
    }
  }
}