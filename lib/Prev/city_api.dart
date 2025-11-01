import 'dart:convert';
import 'package:http/http.dart' as http;

//Model Class for City
class City {
  final String name;
  final String Countryname;
  final String countryCode;
  final double lat;
  final double lng;
  City({required this.name, required this.Countryname, required this.countryCode, required this.lat, required this.lng});
}

class CityApi {
  static Future<List<City>> searchCities(String query) async {
    final response = await http.get(
      Uri.parse(
        'http://api.geonames.org/searchJSON?q=$query&maxRows=10&username=SyedaUmaima',
      ),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = jsonDecode(response.body);
      // Extract the list of cities from the response
      List<dynamic> cities =
          data['geonames']; // According to GeoNames documentation, the cities are in 'geonames' array
      // Convert each city to a string (using the 'name' property) and return the list
      return cities
          .map<City>(
            (city) => City(
              name: city['name'] as String,
              Countryname: city['countryName'] as String,
              countryCode: city['countryCode'] as String,
              lat: double.tryParse(city['lat'].toString()) ?? 0.0,
              lng: double.tryParse(city['lng'].toString()) ?? 0.0,
            ),
          )
          .toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }
}
