// Data model for hourly weather forecast
class HourlyWeatherModel {
  final DateTime dateTime;         
  final String temperature;  
  final String description;
  final String icon;             
  final int humidity; 
  final double windSpeed;        
  final double feelsLike;
  final int chanceOfRain;     
  
  HourlyWeatherModel({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.chanceOfRain,
  });
  
  // Factory constructor to convert OpenWeatherMap 5-day forecast API response to HourlyWeatherModel
  factory HourlyWeatherModel.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toStringAsFixed(1), // uses main object (like current weather) instead of daily aggregated temp
      description: json['weather'][0]['description'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0, // from main object
      windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(), // from wind object
      feelsLike: (json['main']['feels_like'] ?? 0.0).toDouble(), // from main object
      chanceOfRain: ((json['pop'] ?? 0.0) * 100).round(),
    );
  }
  
  /// Method to convert HourlyWeatherModel back to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.millisecondsSinceEpoch,
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'feelsLike': feelsLike,
      'chanceOfRain': chanceOfRain,
    };
  }
  
  //Getter methods for formatted data
  String get hourString {
    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }
  String get temperatureWithUnit => '${temperature}°C';
  String get rainChanceString => '$chanceOfRain%';
}

// Example JSON structure from OpenWeatherMap 5-day forecast API:
// {
//   "dt": 1642424400,
//   "main": {
//     "temp": 276.5,
//     "feels_like": 272.3,
//     "humidity": 85
//   },
//   "weather": [{
//     "description": "light snow",
//     "icon": "13n"
//   }],
//   "wind": {
//     "speed": 3.2
//   },
//   "pop": 0.75
// }