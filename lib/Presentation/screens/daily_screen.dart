import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/models/daily_weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/utils/country_helper.dart';
import '../widgets/weather_card.dart';

class DailyScreen extends StatefulWidget {
  final CityModel? selectedCity;     // Currently selected city 
  
  const DailyScreen({
    Key? key,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  // State variables
  bool _isLoading = false;                       
  String _errorMessage = '';                     
  List<DailyWeatherModel> _dailyForecasts = [];  
  int _selectedDayIndex = 0;                     
  
  @override
  void initState() {
    super.initState();
    if (widget.selectedCity != null) {
      _loadDailyForecast();
    }
  }

  @override
  void didUpdateWidget(DailyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reload forecast data if city changed
    if (widget.selectedCity != oldWidget.selectedCity && widget.selectedCity != null) {
      _loadDailyForecast();
    }
  }

  Future<void> _loadDailyForecast() async {
    if (widget.selectedCity == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final forecasts = await WeatherRepository.getDailyForecast(widget.selectedCity!);
      
      if (mounted) // Prevent  state update after widget disposal  
      {
        setState(() {
          _dailyForecasts = forecasts;
          _isLoading = false;
          _selectedDayIndex = 0; // Reset selection to first day
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load daily forecast. Please try again.';
          _isLoading = false;
          _dailyForecasts = [];
        });
      }
    }
  }

  // Handles refresh action
  Future<void> _onRefresh() async {
    await _loadDailyForecast(); //Reloads data when user pulls down to refresh
  }

  // Handles day selection
  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
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
                  else if (_dailyForecasts.isNotEmpty)
                    _buildDailyContent()
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
          'Daily Forecast',
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
            'Please search and select a city to view daily forecast.',
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
        message: 'Loading daily forecast...',
        size: 32,
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState() {
    return Center(
      child: AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadDailyForecast,
        icon: Icons.today,
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
            Icons.today,
            size: 64,
            color: AppConstants.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Daily Data',
            style: AppConstants.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadDailyForecast,
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

  /// Builds the daily forecast content
  Widget _buildDailyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal scrollable day selector
        _buildDaySelector(),
        
        const SizedBox(height: 20),
        
        // Selected day details
        if (_selectedDayIndex < _dailyForecasts.length)
          _buildSelectedDayDetails(),
        
        const SizedBox(height: 20),
        
        // Daily overview list
        _buildDailyOverview(),
      ],
    );
  }

  /// Builds the horizontal day selector
  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next ${_dailyForecasts.length} Days',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dailyForecasts.length,
            itemBuilder: (context, index) {
              final forecast = _dailyForecasts[index];
              return GestureDetector(
                onTap: () => _onDaySelected(index),
                child: CompactWeatherCard(
                  time: index == 0 ? 'Today' : forecast.dayName.substring(0, 3), // Show "Today" for first day, abbreviated day name for others
                  temperature: forecast.temperatureRange,
                  description: forecast.description,
                  isSelected: index == _selectedDayIndex,
                  icon: const Icon(
                    Icons.wb_sunny,
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

  /// Builds the selected day details
  Widget _buildSelectedDayDetails() {
    final selectedForecast = _dailyForecasts[_selectedDayIndex];
    final dayLabel = _selectedDayIndex == 0 ? 'Today' : selectedForecast.dayName;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Forecast - $dayLabel',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // Main weather card for selected day
        WeatherCard(
          title: '$dayLabel - ${selectedForecast.dateString}',
          temperature: selectedForecast.temperatureRange,
          subtitle: selectedForecast.description.toUpperCase(),
          additionalInfo: 'High: ${selectedForecast.maxTemperature}°C • Low: ${selectedForecast.minTemperature}°C',
          icon: const Icon(
            Icons.today,
            color: AppConstants.accentColor,
            size: 24,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Details grid for selected day
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
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
            
            // UV Index card
            WeatherCard(
              title: 'UV Index',
              temperature: selectedForecast.uvIndex.toStringAsFixed(1),
              subtitle: selectedForecast.uvIndexDescription,
              icon: const Icon(
                Icons.wb_sunny,
                color: AppConstants.accentColor,
                size: 20,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Sunrise and sunset
        _buildSunriseSunset(selectedForecast),
      ],
    );
  }

  /// Builds sunrise and sunset information
  Widget _buildSunriseSunset(DailyWeatherModel forecast) {
    return Row(
      children: [
        Expanded(
          child: WeatherCard(
            title: 'Sunrise',
            temperature: forecast.sunrise,
            icon: const Icon(
              Icons.wb_sunny_outlined,
              color: Colors.orange,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: WeatherCard(
            title: 'Sunset',
            temperature: forecast.sunset,
            icon: const Icon(
              Icons.brightness_3,
              color: Colors.deepOrange,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the daily overview list
  Widget _buildDailyOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Overview',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // List of all days
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dailyForecasts.length,
          itemBuilder: (context, index) {
            final forecast = _dailyForecasts[index];
            final dayLabel = index == 0 ? 'Today' : forecast.dayName;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                tileColor: AppConstants.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppConstants.accentColor.withOpacity(0.2),
                  child: Text(
                    forecast.dateString.split(' ')[1], // Day number
                    style: const TextStyle(
                      color: AppConstants.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dayLabel,
                        style: AppConstants.bodyTextStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      forecast.temperatureRange,
                      style: AppConstants.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        forecast.description,
                        style: const TextStyle(
                          color: AppConstants.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      forecast.rainChanceString,
                      style: const TextStyle(
                        color: AppConstants.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.wb_cloudy,
                      color: AppConstants.accentColor,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
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