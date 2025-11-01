import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/utils/country_helper.dart';
import '../widgets/weather_card.dart';

/// Home Screen - Displays current weather information
/// This screen shows detailed current weather data for the selected city
class HomeScreen extends StatefulWidget {
  final CityModel? selectedCity;     // Currently selected city
  
  const HomeScreen({
    Key? key,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables
  bool _isWeatherLoading = false;    // Tracks if Weather API call is in progress
  String _errorMessage = '';         // Stores error messages
  WeatherModel? _currentWeather;     // Stores current weather data
  
  @override
  void initState() {
    super.initState();
    // Load weather data if city is already selected
    if (widget.selectedCity != null) {
      _loadWeatherData();
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reload weather data if city changed
    if (widget.selectedCity != oldWidget.selectedCity && widget.selectedCity != null) {
      _loadWeatherData();
    }
  }

  /// Loads current weather data for the selected city
  Future<void> _loadWeatherData() async {
    if (widget.selectedCity == null) return;
    
    setState(() {
      _isWeatherLoading = true;
      _errorMessage = '';
    });

    try {
      // Call repository to get current weather
      final weather = await WeatherRepository.getCurrentWeather(widget.selectedCity!);
      
      if (mounted) {
        setState(() {
          _currentWeather = weather;
          _isWeatherLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppConstants.errorWeatherFetch;
          _isWeatherLoading = false;
          _currentWeather = null;
        });
      }
    }
  }

  /// Handles refresh action
  Future<void> _onRefresh() async {
    await _loadWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppConstants.accentColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 20),
                  
                  // Main content based on state
                  if (widget.selectedCity == null)
                    _buildNoCitySelected()
                  else if (_isWeatherLoading)
                    _buildLoadingState()
                  else if (_errorMessage.isNotEmpty)
                    _buildErrorState()
                  else if (_currentWeather != null)
                    _buildWeatherContent()
                  else
                    _buildNoDataState(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Weather',
          style: AppConstants.titleTextStyle,
        ),
        if (widget.selectedCity != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                CountryHelper.countryCodeToEmoji(widget.selectedCity!.countryCode),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.selectedCity!.displayName,
                  style: AppConstants.subtitleTextStyle,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Builds the no city selected state
  Widget _buildNoCitySelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.location_off,
            size: 64,
            color: AppConstants.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Location Selected',
            style: AppConstants.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please search and select a city to view weather information.',
            style: AppConstants.subtitleTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the loading state
  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(
        message: 'Loading weather data...',
        size: 32,
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState() {
    return Center(
      child: AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadWeatherData,
        icon: Icons.cloud_off,
      ),
    );
  }

  /// Builds the no data state
  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.cloud_off,
            size: 64,
            color: AppConstants.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Weather Data',
            style: AppConstants.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadWeatherData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: AppConstants.textColor,
            ),
            child: const Text('Load Weather'),
          ),
        ],
      ),
    );
  }

  /// Builds the weather content
  Widget _buildWeatherContent() {
    if (_currentWeather == null) return const SizedBox();
    
    return Column(
      children: [
        // Main weather card
        WeatherCard(
          title: 'Current Temperature',
          temperature: _currentWeather!.temperatureWithUnit,
          subtitle: _currentWeather!.description.toUpperCase(),
          additionalInfo: _currentWeather!.feelsLikeString,
          icon: Icon(
            Icons.wb_sunny,
            color: AppConstants.accentColor,
            size: 24,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Weather details grid
        _buildWeatherDetailsGrid(),
        
        const SizedBox(height: 16),
        
        // Last updated info
        _buildLastUpdatedInfo(),
      ],
    );
  }

  /// Builds the weather details grid
  Widget _buildWeatherDetailsGrid() {
    if (_currentWeather == null) return const SizedBox();
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        // Humidity card
        WeatherCard(
          title: 'Humidity',
          temperature: '${_currentWeather!.humidity}%',
          icon: const Icon(
            Icons.water_drop,
            color: AppConstants.accentColor,
            size: 20,
          ),
        ),
        
        // Wind speed card
        WeatherCard(
          title: 'Wind Speed',
          temperature: '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s',
          icon: const Icon(
            Icons.air,
            color: AppConstants.accentColor,
            size: 20,
          ),
        ),
        
        // Pressure card
        WeatherCard(
          title: 'Pressure',
          temperature: '${_currentWeather!.pressure} hPa',
          icon: const Icon(
            Icons.compress,
            color: AppConstants.accentColor,
            size: 20,
          ),
        ),
        
        // Feels like card
        WeatherCard(
          title: 'Feels Like',
          temperature: '${_currentWeather!.feelsLike.toStringAsFixed(1)}°C',
          icon: const Icon(
            Icons.thermostat,
            color: AppConstants.accentColor,
            size: 20,
          ),
        ),
      ],
    );
  }

  /// Builds the last updated information
  Widget _buildLastUpdatedInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.update,
            color: AppConstants.secondaryTextColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Last updated: ${DateTime.now().toString().substring(11, 19)}',
            style: const TextStyle(
              color: AppConstants.secondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}