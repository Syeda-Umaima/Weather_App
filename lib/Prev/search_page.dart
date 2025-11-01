// import 'package:flutter/material.dart';
// import 'package:weather_app/city_api.dart';
// import 'dart:async';
// import 'home_page.dart';
// import 'package:weather_app/weather_api.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => SearchPageState();
// }

// class SearchPageState extends State<SearchPage> {
 
  // Controller for the search text field
  // TextEditingController _searchController = TextEditingController();

  // State variables
//   bool isCityLoading = false; // Tracks if City API call is in progress
//   bool isWeatherLoading = false; // Tracks if Weather API call is in progress
//   String errorMessage = ''; // Stores error messages
//   List<City> filteredCities =
//       []; // Stores cities from API response and stores City object instead of String
  
//   Timer? debounce; // Timer for debouncing API calls
//   Weather? currentWeather; // Stores the current weather data

//   @override
//     String countryCodeToEmoji(String code) {
//   return code.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'), (match) {
//     return String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397);
//   });
// }

//   void initState() {
//     super.initState();
    // Initialize filteredCities as empty list
  //   filteredCities = [];
  // }

  // @override
  // void dispose() {
    // Cancel any active timer to prevent memory leaks
    // debounce?.cancel();
    // Dispose the text controller
  //   _searchController.dispose();
  //   super.dispose();
  // }

  // void filterCities(String query) {
    // Cancel any active timer
    // if (debounce?.isActive ?? false) debounce!.cancel();

    // Handle empty query
    // if (query.isEmpty) {
    //   setState(() {
    //     filteredCities = [];
    //     isCityLoading = false;
    //     errorMessage = '';
    //     currentWeather = null; // Clear previous weather on new search
    //   });
    //   return; // Exit early for empty query
    // }
    //Remove previous weather when user starts new search
    // setState(() {
    //   isCityLoading = true;
    //   currentWeather = null; // Clear previous weather on new search
    //   errorMessage = '';
    // });
    // Debounce the API call
  //   debounce = Timer(const Duration(milliseconds: 500), () async {
  //     try {
  //       final cities = await CityApi.searchCities(query);
  //       setState(() {
  //         filteredCities = cities;
  //         isCityLoading = false;
  //       });
  //     } catch (e) {
  //       setState(() {
  //         errorMessage = 'Failed to fetch cities. Please try again.';
  //         isCityLoading = false;
  //       });
  //     }
  //   });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
  //     home: Scaffold(
  //       body: Column(
  //         children: [
  //           Padding(
  //             padding: EdgeInsets.all(25),
  //             child: Text(
  //               "Pick Location",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.only(left: 20, right: 20),
  //             child: Text(
  //               "Find the area or city you want to check the weather for",
  //               style: TextStyle(color: Colors.white70, fontSize: 18),
  //             ),
  //           ),
  //           Padding(padding: EdgeInsets.all(16)),
  //           Padding(
  //             padding: EdgeInsets.only(left: 16, right: 16),
  //             child: // Search Text Field
  //             TextField(
  //               controller: _searchController,
  //               onChanged: filterCities, // Call filter on text change
  //               decoration: InputDecoration(
  //                 labelText: "Search your City",
  //                 prefixIcon: Icon(Icons.location_on),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),
  //             ),
  //           ),

            // Show loading indicator when City API call is in progress
            // if (isCityLoading)
            //   Padding(
            //     padding: EdgeInsets.symmetric(vertical: 20),
            //     child: CircularProgressIndicator(),
            //   ),

            // Show error message if any
            // if (errorMessage.isNotEmpty)
            //   Padding(
            //     padding: EdgeInsets.all(16),
            //     child: Text(
            //       errorMessage,
            //       style: TextStyle(color: Colors.red),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),

            //Show weather Loading Indicatorwhen weather API Call is in progress
            // if (isWeatherLoading)
            //   Padding(
            //     padding: EdgeInsets.symmetric(vertical: 10),
            //     child: CircularProgressIndicator(),
            //   ),

            // Show current weather if available
            // Padding(
            //   padding: EdgeInsets.all(16),
            //   child: Text(
            //     'Current Temperature: ${currentWeather!.temperature}',
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            // ),

            // Show list of cities when available and not loading
  //           if (filteredCities.isNotEmpty && !isCityLoading)
  //             Expanded(
  //               child: ListView.builder(
  //                 itemCount: filteredCities.length,
  //                 itemBuilder: (context, index) {
  //                   //Get selected city object
  //                   City city = filteredCities[index];
  //                   return ListTile(
  //                     onTap: () async {
  //                       setState(() {
  //                         isWeatherLoading = true; //Start Weather Loading
  //                         errorMessage = ''; //Clear prev. errors
  //                       });
  //                       try {
  //                         //Call API for weather
  //                         final weather = await WeatherApi.CheckWeather(
  //                           city.lat.toString(),
  //                           city.lng.toString(),
  //                         );
  //                         setState(() {
  //                           currentWeather = weather; // Store the weather data
  //                           _searchController.text =
  //                               city.name; // Set selected city in search field
  //                           filteredCities = [];
  //                           isWeatherLoading = false; //Stop Weather Loading

  //                           Navigator.of(context).push(
  //                             MaterialPageRoute(
  //                               builder: (context) => HomeScreen(
  //                                 temperature: currentWeather!.temperature,
  //                               ),
  //                             ),
  //                           );
  //                         });
  //                       } catch (e) {
  //                         setState(() {
  //                           errorMessage =
  //                               'Failed to fetch Weather. Please try again.';
  //                           filteredCities = [];
  //                           isWeatherLoading = false;
  //                         });
  //                       }
  //                     },
  //                     title: Text('${countryCodeToEmoji(city.countryCode)}, ${city.name}, ${city.Countryname}'),
  //                     subtitle: Text(
  //                       'Lat: ${city.lat.toStringAsFixed(4)}, Lng: ${city.lng.toStringAsFixed(4)}',
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //         ],
  //       ),
        
  //     ),
  //   );
  // }
// }
