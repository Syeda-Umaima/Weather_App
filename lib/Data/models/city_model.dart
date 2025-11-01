// Data model for city information
class CityModel {
  final String name;           
  final String countryName;    
  final String countryCode;     
  final double latitude;       
  final double longitude;        
  /// Constructor for CityModel instance
  CityModel({
    required this.name,
    required this.countryName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });
  
  // Factory constructor (that doesnot always create new instance) to convert JSON data from API response to CityModel object
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      countryName: json['countryName'] as String,
      countryCode: json['countryCode'] as String,
      latitude: double.tryParse(json['lat'].toString()) ?? 0.0,
      longitude: double.tryParse(json['lng'].toString()) ?? 0.0,
    );
  }
  
  /// Method to convert CityModel object back to JSON (for storage or API calls)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'countryName': countryName,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  
  // Getter methods for formatted display 
  String get displayName => '$name, $countryName';
  String get coordinatesString => 
      'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
}