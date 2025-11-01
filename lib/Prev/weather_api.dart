// import 'dart:convert';

// import 'package:http/http.dart' as http;

// //Model class for weather data to hold information that we get from the API
// class Weather {
//   final String temperature;
//   Weather({required this.temperature});
// }

// class WeatherApi {
//   static Future<Weather> CheckWeather(String lat, String lng) async {
//     // Add units=metric to get Celsius in response instead of Kelvin
//     final response = await http.get(
//       Uri.parse(
//         'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&units=metric&appid=6eac9eb85ae633256d13e1666508ba47',
//       ),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       final temperatureValue = data['main']['temp'].toStringAsFixed(1);

//       return Weather(temperature: temperatureValue); // This returns a Weather object
//     } else {
//       throw Exception('Failed to load Weather Data');
//     }
//   }
// }
