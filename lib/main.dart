import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'data/models/city_model.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/hourly_screen.dart';
import 'presentation/screens/daily_screen.dart';
import 'presentation/screens/weekly_screen.dart';
import 'presentation/widgets/bottom_nav_bar.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App configuration
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      
      // App theme configuration
      theme: ThemeData(
        // Primary color scheme
        primarySwatch: Colors.blue,
        primaryColor: AppConstants.primaryColor,
        
        // Background and surface colors
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        
        // Text theme
        textTheme: const TextTheme(
          bodyLarge: AppConstants.bodyTextStyle,
          bodyMedium: AppConstants.bodyTextStyle,
          titleLarge: AppConstants.titleTextStyle,
        ),
        
        // Dark theme configuration
        brightness: Brightness.dark,
        
        // App bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
          foregroundColor: AppConstants.textColor,
          elevation: 0,
        ),
      ),
      
      // Home screen
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Navigation state
  int _selectedIndex = 0;           // Currently selected tab index
  CityModel? _selectedCity;         // Currently selected city for weather data
  
  // All app screens
  late List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  // Initialize all screens with necessary dependencies
  void _initializeScreens() {
    _screens = [
      // Search screen (index 0)
      SearchScreen(
        onCitySelected: _onCitySelected,
        selectedCity: _selectedCity,
      ),
      
      // Home screen (index 1) - Current weather
      HomeScreen(
        selectedCity: _selectedCity,
      ),
      
      // Hourly screen (index 2) - Hourly forecast
      HourlyScreen(
        selectedCity: _selectedCity,
      ),
      
      // Daily screen (index 3) - Daily forecast
      DailyScreen(
        selectedCity: _selectedCity,
      ),
      
      // Weekly screen (index 4) - Weekly forecast
      WeeklyScreen(
        selectedCity: _selectedCity,
      ),
    ];
  }

  void _onCitySelected(CityModel city) {
    setState(() {
      _selectedCity = city;
      _initializeScreens(); 
      
      // Auto-navigate to home screen after city selection
      _selectedIndex = TabNavigationHelper.homeTab;
    });
    
    print('🏙️ City selected: ${city.displayName}'); 
  }

  void _onItemTapped(int index) {
    // Check if weather data is required for the selected tab
    if (_selectedCity == null && TabNavigationHelper.requiresWeatherData(index)) {
      _showSelectCityDialog();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
    
    print('📱 Tab selected: ${TabNavigationHelper.getTabTitle(index)}'); 
  }

  void _showSelectCityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          title: const Text(
            'No Location Selected',
            style: TextStyle(color: AppConstants.textColor),
          ),
          content: const Text(
            'Please search and select a city first to view weather information.',
            style: TextStyle(color: AppConstants.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedIndex = TabNavigationHelper.searchTab;
                });
              },
              child: const Text(
                'Go to Search',
                style: TextStyle(color: AppConstants.accentColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppConstants.secondaryTextColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Debug helper to log app lifecycle events
/// This can be useful for debugging navigation and state management
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('🔄 App resumed');
        break;
      case AppLifecycleState.inactive:
        print('⏸️ App inactive');
        break;
      case AppLifecycleState.paused:
        print('⏸️ App paused');
        break;
      case AppLifecycleState.detached:
        print('🔌 App detached');
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
