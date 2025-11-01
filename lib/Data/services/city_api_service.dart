import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city_model.dart';
import '../../core/constants/api_constants.dart';

// Handles all city-related API calls, communicates with GeoNames API to search for cities

class CityApiService {
  static Future<List<CityModel>> searchCities(String query) async {
    try {
      // Construct the API URL with query parameters
      final url = Uri.parse(
        '${ApiConstants.geoNamesBaseUrl}/searchJSON?q=$query&maxRows=${ApiConstants.maxCityResults}&username=${ApiConstants.geoNamesUsername}',
      );
      
      print('🌍 Searching cities for: $query'); // Debug log
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if the response contains the expected data structure
        if (data['geonames'] == null) {
          print('⚠️ No geonames found in response');
          return [];
        }
        
        List<dynamic> citiesJson = data['geonames']; //Extract cities array
        print('✅ Found ${citiesJson.length} cities'); 

        // Convert each JSON object to a CityModel 
        return citiesJson
            .map<CityModel>((cityJson) => CityModel.fromJson(cityJson))
            .toList();
            
      } else {
        print('❌ City API Error: ${response.statusCode}');
        throw Exception('Failed to load cities. Status code: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ City API Exception: $e');
      throw Exception('Failed to fetch cities: $e');
    }
  }
}