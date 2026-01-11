import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/api_constants.dart';
import 'core/widgets/splash_screen.dart';
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
  bool _showSplash = true;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    });
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
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
        useMaterial3: true,
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
        useMaterial3: true,
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
      
      home: _showSplash 
    ? SplashScreen(onComplete: _onSplashComplete)
    : MainScreen(onToggleTheme: _toggleTheme),
    );
  }
}

// Screen shown when API keys are not configured
class ApiConfigurationScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  
  const ApiConfigurationScreen({
    Key? key,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.getBackgroundColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConstants.warningColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  size: 64,
                  color: AppConstants.warningColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'API Configuration Required',
                style: AppConstants.getTitleStyle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This app requires API keys to function. Please run the app with the following command:',
                style: AppConstants.getSubtitleStyle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'flutter run \\',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppConstants.getTextColor(context),
                      ),
                    ),
                    Text(
                      '  --dart-define=OPENWEATHER_API_KEY=your_key \\',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppConstants.getPrimaryColor(context),
                      ),
                    ),
                    Text(
                      '  --dart-define=GEONAMES_USERNAME=your_username',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppConstants.getPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Get your free API keys from:',
                style: AppConstants.getBodyStyle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '• OpenWeatherMap: openweathermap.org/api\n• GeoNames: geonames.org/login',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusChip(
                    context,
                    'Weather API',
                    ApiConstants.hasWeatherApiKey,
                  ),
                  const SizedBox(width: 12),
                  _buildStatusChip(
                    context,
                    'GeoNames API',
                    ApiConstants.hasGeoNamesCredentials,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, bool isConfigured) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isConfigured 
            ? AppConstants.successColor.withOpacity(0.1)
            : AppConstants.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfigured ? AppConstants.successColor : AppConstants.errorColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfigured ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isConfigured ? AppConstants.successColor : AppConstants.errorColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isConfigured ? AppConstants.successColor : AppConstants.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
