import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/models/hourly_weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/utils/country_helper.dart';
import '../widgets/weather_card.dart';

/// Hourly Screen - Displays hourly weather forecast
/// This screen shows hourly weather data for the next 24 hours for the selected city
class HourlyScreen extends StatefulWidget {
  final CityModel? selectedCity;     // Currently selected city
  
  const HourlyScreen({
    Key? key,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<HourlyScreen> createState() => _HourlyScreenState();
}

class _HourlyScreenState extends State<HourlyScreen> {
  // State variables
  bool _isLoading = false;                         // Tracks if API call is in progress
  String _errorMessage = '';                       // Stores error messages
  List<HourlyWeatherModel> _hourlyForecasts = [];  // Stores hourly forecast data
  int _selectedHourIndex = 0;                      // Currently selected hour index
  
  @override
  void initState() {
    super.initState();
    // Load hourly forecast if city is already selected
    if (widget.selectedCity != null) {
      _loadHourlyForecast();
    }
  }

  @override
  void didUpdateWidget(HourlyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reload forecast data if city changed
    if (widget.selectedCity != oldWidget.selectedCity && widget.selectedCity != null) {
      _loadHourlyForecast();
    }
  }

  /// Loads hourly forecast data for the selected city
  Future<void> _loadHourlyForecast() async {
    if (widget.selectedCity == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Call repository to get hourly forecast
      final forecasts = await WeatherRepository.getHourlyForecast(widget.selectedCity!);
      
      if (mounted) {
        setState(() {
          _hourlyForecasts = forecasts;
          _isLoading = false;
          _selectedHourIndex = 0; // Reset selection to first hour
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load hourly forecast. Please try again.';
          _isLoading = false;
          _hourlyForecasts = [];
        });
      }
    }
  }

  /// Handles refresh action
  Future<void> _onRefresh() async {
    await _loadHourlyForecast();
  }

  /// Handles hour selection
  void _onHourSelected(int index) {
    setState(() {
      _selectedHourIndex = index;
    });
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
                  else if (_isLoading)
                    _buildLoadingState()
                  else if (_errorMessage.isNotEmpty)
                    _buildErrorState()
                  else if (_hourlyForecasts.isNotEmpty)
                    _buildHourlyContent()
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
          'Hourly Forecast',
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
            'Please search and select a city to view hourly forecast.',
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
        message: 'Loading hourly forecast...',
        size: 32,
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState() {
    return Center(
      child: AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadHourlyForecast,
        icon: Icons.schedule,
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
            Icons.schedule,
            size: 64,
            color: AppConstants.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Hourly Data',
            style: AppConstants.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadHourlyForecast,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: AppConstants.textColor,
            ),
            child: const Text('Load Forecast'),
          ),
        ],
      ),
    );
  }

  /// Builds the hourly forecast content
  Widget _buildHourlyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal scrollable hour selector
        _buildHourSelector(),
        
        const SizedBox(height: 20),
        
        // Selected hour details
        if (_selectedHourIndex < _hourlyForecasts.length)
          _buildSelectedHourDetails(),
        
        const SizedBox(height: 20),
        
        // Next hours overview
        _buildNextHoursOverview(),
      ],
    );
  }

  /// Builds the horizontal hour selector
  Widget _buildHourSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next 24 Hours',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hourlyForecasts.length,
            itemBuilder: (context, index) {
              final forecast = _hourlyForecasts[index];
              return GestureDetector(
                onTap: () => _onHourSelected(index),
                child: CompactWeatherCard(
                  time: forecast.hourString,
                  temperature: forecast.temperatureWithUnit,
                  description: forecast.description,
                  isSelected: index == _selectedHourIndex,
                  icon: const Icon(
                    Icons.wb_cloudy,
                    size: 20,
                    color: AppConstants.accentColor,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the selected hour details
  Widget _buildSelectedHourDetails() {
    final selectedForecast = _hourlyForecasts[_selectedHourIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Forecast - ${selectedForecast.hourString}',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // Main weather card for selected hour
        WeatherCard(
          title: 'Temperature at ${selectedForecast.hourString}',
          temperature: selectedForecast.temperatureWithUnit,
          subtitle: selectedForecast.description.toUpperCase(),
          additionalInfo: 'Feels like ${selectedForecast.feelsLike.toStringAsFixed(1)}°C',
          icon: const Icon(
            Icons.schedule,
            color: AppConstants.accentColor,
            size: 24,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Details grid for selected hour
        GridView.count(
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
              temperature: '${selectedForecast.humidity}%',
              icon: const Icon(
                Icons.water_drop,
                color: AppConstants.accentColor,
                size: 20,
              ),
            ),
            
            // Wind speed card
            WeatherCard(
              title: 'Wind Speed',
              temperature: '${selectedForecast.windSpeed.toStringAsFixed(1)} m/s',
              icon: const Icon(
                Icons.air,
                color: AppConstants.accentColor,
                size: 20,
              ),
            ),
            
            // Rain chance card
            WeatherCard(
              title: 'Rain Chance',
              temperature: selectedForecast.rainChanceString,
              icon: const Icon(
                Icons.grain,
                color: AppConstants.accentColor,
                size: 20,
              ),
            ),
            
            // Feels like card
            WeatherCard(
              title: 'Feels Like',
              temperature: '${selectedForecast.feelsLike.toStringAsFixed(1)}°C',
              icon: const Icon(
                Icons.thermostat,
                color: AppConstants.accentColor,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the next hours overview
  Widget _buildNextHoursOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Overview',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // List of all hours
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hourlyForecasts.length,
          itemBuilder: (context, index) {
            final forecast = _hourlyForecasts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tileColor: AppConstants.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppConstants.accentColor.withOpacity(0.2),
                  child: Text(
                    forecast.hourString,
                    style: const TextStyle(
                      color: AppConstants.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  forecast.temperatureWithUnit,
                  style: AppConstants.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  forecast.description,
                  style: const TextStyle(
                    color: AppConstants.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      forecast.rainChanceString,
                      style: const TextStyle(
                        color: AppConstants.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${forecast.windSpeed.toStringAsFixed(1)} m/s',
                      style: const TextStyle(
                        color: AppConstants.secondaryTextColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}