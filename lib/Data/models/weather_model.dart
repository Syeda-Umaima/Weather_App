// Data model for current weather information for a location
class WeatherModel {
  final String temperature;  
  final String description;       
  final String icon;     
  final int humidity;
  final double windSpeed;    
  final int pressure;
  final double feelsLike;
  final String cityName;  // for display and identification
  final String countryCode;  
  
  WeatherModel({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.feelsLike,
    required this.cityName,
    required this.countryCode,
  });
  
  // Factory constructor to create WeatherModel from JSON response
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['main']['temp'].toStringAsFixed(1),
      description: json['weather'][0]['description'] ?? 'Unknown', // In weather array, API can return multiple conditions for a location, so to use the first one
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      feelsLike: (json['main']['feels_like'] ?? 0.0).toDouble(),
      cityName: json['name'] ?? 'Unknown',
      countryCode: json['sys']['country'] ?? 'XX',
    );
  }
  
  // Method to convert WeatherModel back to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'feelsLike': feelsLike,
      'cityName': cityName,
      'countryCode': countryCode,
    };
  }
  
  // Getter methods for formatted data
  String get temperatureWithUnit => '${temperature}°C';
  String get feelsLikeString => 'Feels like ${feelsLike.toStringAsFixed(1)}°C';
  String get windSpeedString => 'Wind: ${windSpeed.toStringAsFixed(1)} m/s';
  String get humidityString => 'Humidity: $humidity%';
  String get pressureString => 'Pressure: $pressure hPa';
}

// JSON Structure Example
// {
//   "main": {
//     "temp": 22.5,
//     "feels_like": 23.8,
//     "humidity": 65,
//     "pressure": 1013
//   },
//   "weather": [
//     {
//       "description": "Clear sky",
//       "icon": "01d"
//     }
//   ],
//   "wind": {
//     "speed": 3.2
//   },
//   "name": "Paris",
//   "sys": {
//     "country": "FR"
//   }
// }

// Two weather conditions example: THUNDERSTORM with RAIN
// "weather": [
//   {
//     "id": 211,  // Thunderstorm (primary)
//     "main": "Thunderstorm",
//     "description": "thunderstorm", 
//     "icon": "11d"
//   },
//   {
//     "id": 501,  // Rain (secondary)
//     "main": "Rain", 
//     "description": "moderate rain",
//     "icon": "10d"
//   }
// ]