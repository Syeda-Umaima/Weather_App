import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'data/models/city_model.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/hourly_screen.dart';
import 'presentation/screens/daily_screen.dart';
import 'presentation/screens/weekly_screen.dart';
import 'presentation/widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      
      // Light Theme
      theme: ThemeData(
        useMaterial3: true,  // Enable Material 3 here
        brightness: Brightness.light,
        primaryColor: AppConstants.lightPrimary,
        scaffoldBackgroundColor: AppConstants.lightBackground,
        colorScheme: ColorScheme.light(
          primary: AppConstants.lightPrimary,
          secondary: AppConstants.lightAccent,
          surface: AppConstants.lightCardBackground,
          background: AppConstants.lightBackground,
        ),
        textTheme: TextTheme(
          bodyLarge: AppConstants.lightBodyTextStyle,
          bodyMedium: AppConstants.lightBodyTextStyle,
          titleLarge: AppConstants.lightTitleTextStyle,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.lightBackground,
          foregroundColor: AppConstants.lightText,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      
      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,  // Enable Material 3 here
        brightness: Brightness.dark,
        primaryColor: AppConstants.darkPrimary,
        scaffoldBackgroundColor: AppConstants.darkBackground,
        colorScheme: ColorScheme.dark(
          primary: AppConstants.darkPrimary,
          secondary: AppConstants.darkAccent,
          surface: AppConstants.darkCardBackground,
          background: AppConstants.darkBackground,
        ),
        textTheme: TextTheme(
          bodyLarge: AppConstants.darkBodyTextStyle,
          bodyMedium: AppConstants.darkBodyTextStyle,
          titleLarge: AppConstants.darkTitleTextStyle,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.darkBackground,
          foregroundColor: AppConstants.darkText,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      
      home: MainScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  
  const MainScreen({
    Key? key,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  CityModel? _selectedCity;
  late List<Widget> _screens;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeScreens();
    
    _fadeController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeScreens() {
    _screens = [
      SearchScreen(
        onCitySelected: _onCitySelected,
        selectedCity: _selectedCity,
        onToggleTheme: widget.onToggleTheme,
      ),
      HomeScreen(selectedCity: _selectedCity),
      HourlyScreen(selectedCity: _selectedCity),
      DailyScreen(selectedCity: _selectedCity),
      WeeklyScreen(selectedCity: _selectedCity),
    ];
  }

  void _onCitySelected(CityModel city) {
    setState(() {
      _selectedCity = city;
      _initializeScreens();
      _selectedIndex = TabNavigationHelper.homeTab;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedCity == null && TabNavigationHelper.requiresWeatherData(index)) {
      _showSelectCityDialog();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  void _showSelectCityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConstants.getCardColor(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.warningColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off_rounded,
                    color: AppConstants.warningColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Location Selected',
                  style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please search and select a city first to view weather information.',
                  style: AppConstants.getBodyStyle(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppConstants.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedIndex = TabNavigationHelper.searchTab;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.getPrimaryColor(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Go to Search'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TabNavigationHelper {
  static const int searchTab = 0;
  static const int homeTab = 1;
  static const int hourlyTab = 2;
  static const int dailyTab = 3;
  static const int weeklyTab = 4;
  
  static String getTabTitle(int index) {
    switch (index) {
      case searchTab:
        return AppConstants.searchLabel;
      case homeTab:
        return AppConstants.homeLabel;
      case hourlyTab:
        return AppConstants.hourlyLabel;
      case dailyTab:
        return AppConstants.dailyLabel;
      case weeklyTab:
        return AppConstants.weeklyLabel;
      default:
        return 'Unknown';
    }
  }
  
  static bool requiresWeatherData(int index) {
    return index == homeTab || 
           index == hourlyTab || 
           index == dailyTab || 
           index == weeklyTab;
  }
}