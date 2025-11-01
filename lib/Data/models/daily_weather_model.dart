// Data model for daily weather forecast
class DailyWeatherModel {
  final DateTime date;
  final String maxTemperature;    
  final String minTemperature;    
  final String description;     
  final String icon;
  final int humidity;
  final double windSpeed;     
  final int chanceOfRain;      
  final double uvIndex;        
  final String sunrise;        
  final String sunset;         
  
  DailyWeatherModel({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.chanceOfRain,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
  });
  
  // Factory constructor to convert JSON response (OpenWeatherMap One Call API daily response) to DailyWeatherModel
  factory DailyWeatherModel.fromJson(Map<String, dynamic> json) {
    // Convert sunrise and sunset (unix) timestamps to readable time
    final sunriseTime = DateTime.fromMillisecondsSinceEpoch(json['sunrise'] * 1000);  //API gives in seconds, convert to milliseconds
    final sunsetTime = DateTime.fromMillisecondsSinceEpoch(json['sunset'] * 1000);
    
    return DailyWeatherModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000), // forecast timestamp 
      maxTemperature: json['temp']['max'].toStringAsFixed(1),
      minTemperature: json['temp']['min'].toStringAsFixed(1),
      description: json['weather'][0]['description'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind_speed'] ?? 0.0).toDouble(),
      chanceOfRain: ((json['pop'] ?? 0.0) * 100).round(), //probability of precipitation convert 0.0 - 1.0 to percentage
      uvIndex: (json['uvi'] ?? 0.0).toDouble(),
      sunrise: '${sunriseTime.hour.toString().padLeft(2, '0')}:${sunriseTime.minute.toString().padLeft(2, '0')}', // format to HH:MM
      sunset: '${sunsetTime.hour.toString().padLeft(2, '0')}:${sunsetTime.minute.toString().padLeft(2, '0')}',
    );
  }
  
  // Method to convert DailyWeatherModel back to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'chanceOfRain': chanceOfRain,
      'uvIndex': uvIndex,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }
  
  // Getter methods for formatted data
  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1]; // from date timestamp 
  }
  
  String get dateString {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}'; 
  }
  
  String get temperatureRange => '${maxTemperature}°/${minTemperature}°'; // compact temperature display like 25.3°/15.6°
  
  String get rainChanceString => '$chanceOfRain%';
  
  //  Converts numeric UV index to risk level description
  String get uvIndexDescription {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }
}

// JSON Structure Example
// {
//   "dt": 1642424400,
//   "sunrise": 1642403344,
//   "sunset": 1642439876,
//   "temp": {
//     "max": 278.9,
//     "min": 275.6
//   },
//   "weather": [{
//     "description": "light rain",
//     "icon": "10d"
//   }],
//   "humidity": 87,
//   "wind_speed": 4.63,
//   "pop": 0.85, 
//   "uvi": 3.2   
// }