import 'daily_weather_model.dart';

// Data model for 7-day weather forecast
class WeeklyWeatherModel {
  // Collection model to manage multiple dailyWeatherModel instances  
  final List<DailyWeatherModel> dailyForecasts; // List of daily forecasts
  final String locationName;                    
  final DateTime lastUpdated;                   
  
  WeeklyWeatherModel({
    required this.dailyForecasts,
    required this.locationName,
    required this.lastUpdated,
  });
  
  // Factory constructor to convert OpenWeatherMap One Call API response to WeeklyWeatherModel
  factory WeeklyWeatherModel.fromJson(Map<String, dynamic> json) {
    // Parse daily forecasts from the API response
    // Iterate through the 'daily' array in the JSON and create DailyWeatherModel instances
    List<DailyWeatherModel> forecasts = [];
    if (json['daily'] != null) {
      for (var dailyData in json['daily']) {
        forecasts.add(DailyWeatherModel.fromJson(dailyData));
      }
    }
    
    return WeeklyWeatherModel(
      dailyForecasts: forecasts,
      locationName: json['timezone'] ?? 'Unknown Location', // Using timezone as a proxy for location name
      lastUpdated: DateTime.now(), // Set to current time as API does not provide last updated time
    );
  }
  
  // Method to convert WeeklyWeatherModel back to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'dailyForecasts': dailyForecasts.map((forecast) => forecast.toJson()).toList(), // Convert each DailyWeatherModel to JSON, forecast.toJson() is calling the toJson method of DailyWeatherModel class
      'locationName': locationName,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
  
  // Accessor methods for easy access to specific days or summary data
  DailyWeatherModel? get todayForecast {
    return dailyForecasts.isNotEmpty ? dailyForecasts.first : null; // Get today's forecast (first item in the list)
  }
  
  DailyWeatherModel? get tomorrowForecast {
    return dailyForecasts.length > 1 ? dailyForecasts[1] : null; // Get tomorrow's forecast (second item in the list)
  }
  
  DailyWeatherModel? getForecastForDay(int dayIndex) {
    if (dayIndex >= 0 && dayIndex < dailyForecasts.length) {
      return dailyForecasts[dayIndex]; //Get forecast for specified day index
    }
    return null;
  }

  int get forecastDaysCount => dailyForecasts.length; // Total number of forecast days available
  
  // AGGREGATE DATA METHODS

  String get weekHighestTemp {
    if (dailyForecasts.isEmpty) return '0°C';
    
    double highest = double.parse(dailyForecasts.first.maxTemperature);
    for (var forecast in dailyForecasts) {
      double temp = double.parse(forecast.maxTemperature); // get max temperature of each day from the list
      if (temp > highest) {
        highest = temp; // swapping
      }
    }
    return '${highest.toStringAsFixed(1)}°C';
  }
  
  String get weekLowestTemp {
    if (dailyForecasts.isEmpty) return '0°C';
    
    double lowest = double.parse(dailyForecasts.first.minTemperature);
    for (var forecast in dailyForecasts) {
      double temp = double.parse(forecast.minTemperature);
      if (temp < lowest) {
        lowest = temp;
      }
    }
    return '${lowest.toStringAsFixed(1)}°C';
  }
  
  double get averageHumidity {
    if (dailyForecasts.isEmpty) return 0.0;
    
    int totalHumidity = 0;
    for (var forecast in dailyForecasts) {
      totalHumidity += forecast.humidity;
    }
    return totalHumidity / dailyForecasts.length;
  }
  
  // Getter methods for formatted data 
  String get lastUpdatedString {
    return '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}';
  }
}

// JSON structure example
//{
//   "timezone": "America/New_York",
//   "daily": [
//     { /* Day 1 data */ },
//     { /* Day 2 data */ },
//     // ... up to 8 days
//   ]
// }