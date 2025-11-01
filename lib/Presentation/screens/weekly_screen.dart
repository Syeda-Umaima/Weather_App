import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/models/weekly_weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/utils/country_helper.dart';
import '../widgets/weather_card.dart';

/// Weekly Screen - Displays weekly weather forecast and statistics
/// This screen shows weekly weather summary and trends for the selected city
class WeeklyScreen extends StatefulWidget {
  final CityModel? selectedCity;     // Currently selected city
  
  const WeeklyScreen({
    Key? key,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  // State variables
  bool _isLoading = false;                  // Tracks if API call is in progress
  String _errorMessage = '';                // Stores error messages
  WeeklyWeatherModel? _weeklyForecast;      // Stores weekly forecast data
  
  @override
  void initState() {
    super.initState();
    // Load weekly forecast if city is already selected
    if (widget.selectedCity != null) {
      _loadWeeklyForecast();
    }
  }

  @override
  void didUpdateWidget(WeeklyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reload forecast data if city changed
    if (widget.selectedCity != oldWidget.selectedCity && widget.selectedCity != null) {
      _loadWeeklyForecast();
    }
  }

  /// Loads weekly forecast data for the selected city
  Future<void> _loadWeeklyForecast() async {
    if (widget.selectedCity == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Call repository to get weekly forecast
      final forecast = await WeatherRepository.getWeeklyForecast(widget.selectedCity!);
      
      if (mounted) {
        setState(() {
          _weeklyForecast = forecast;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load weekly forecast. Please try again.';
          _isLoading = false;
          _weeklyForecast = null;
        });
      }
    }
  }

  /// Handles refresh action
  Future<void> _onRefresh() async {
    await _loadWeeklyForecast();
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
                  else if (_weeklyForecast != null)
                    _buildWeeklyContent()
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
          'Weekly Forecast',
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
            'Please search and select a city to view weekly forecast.',
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
        message: 'Loading weekly forecast...',
        size: 32,
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState() {
    return Center(
      child: AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadWeeklyForecast,
        icon: Icons.date_range,
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
            Icons.date_range,
            size: 64,
            color: AppConstants.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Weekly Data',
            style: AppConstants.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadWeeklyForecast,
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

  /// Builds the weekly forecast content
  Widget _buildWeeklyContent() {
    if (_weeklyForecast == null) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week summary cards
        _buildWeekSummary(),
        
        const SizedBox(height: 20),
        
        // Weekly statistics
        _buildWeeklyStatistics(),
        
        const SizedBox(height: 20),
        
        // Daily breakdown
        _buildDailyBreakdown(),
        
        const SizedBox(height: 20),
        
        // Last updated info
        _buildLastUpdatedInfo(),
      ],
    );
  }

  /// Builds the week summary cards
  Widget _buildWeekSummary() {
    final todayForecast = _weeklyForecast!.todayForecast;
    final tomorrowForecast = _weeklyForecast!.tomorrowForecast;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Week Summary',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // Today and Tomorrow cards
        Row(
          children: [
            if (todayForecast != null)
              Expanded(
                child: WeatherCard(
                  title: 'Today',
                  temperature: todayForecast.temperatureRange,
                  subtitle: todayForecast.description,
                  icon: const Icon(
                    Icons.today,
                    color: AppConstants.accentColor,
                    size: 20,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            if (tomorrowForecast != null)
              Expanded(
                child: WeatherCard(
                  title: 'Tomorrow',
                  temperature: tomorrowForecast.temperatureRange,
                  subtitle: tomorrowForecast.description,
                  icon: const Icon(
                    Icons.calendar_today,
                    color: AppConstants.accentColor,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Week temperature range
        WeatherCard(
          title: 'Week Temperature Range',
          temperature: '${_weeklyForecast!.weekHighestTemp} / ${_weeklyForecast!.weekLowestTemp}',
          subtitle: 'High / Low for the week',
          additionalInfo: 'Average Humidity: ${_weeklyForecast!.averageHumidity.toStringAsFixed(1)}%',
          icon: const Icon(
            Icons.thermostat,
            color: AppConstants.accentColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  /// Builds weekly statistics
  Widget _buildWeeklyStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Statistics',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            // Forecast days count
            WeatherCard(
              title: 'Forecast Days',
              temperature: '${_weeklyForecast!.forecastDaysCount}',
              subtitle: 'Days available',
              icon: const Icon(
                Icons.calendar_today,
                color: AppConstants.accentColor,
                size: 20,
              ),
            ),
            
            // Average humidity
            WeatherCard(
              title: 'Avg Humidity',
              temperature: '${_weeklyForecast!.averageHumidity.toStringAsFixed(1)}%',
              subtitle: 'Week average',
              icon: const Icon(
                Icons.water_drop,
                color: AppConstants.accentColor,
                size: 20,
              ),
            ),
            
            // Highest temperature
            WeatherCard(
              title: 'Week High',
              temperature: _weeklyForecast!.weekHighestTemp,
              subtitle: 'Maximum temp',
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.red,
                size: 20,
              ),
            ),
            
            // Lowest temperature
            WeatherCard(
              title: 'Week Low',
              temperature: _weeklyForecast!.weekLowestTemp,
              subtitle: 'Minimum temp',
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds daily breakdown for the week
  Widget _buildDailyBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Breakdown',
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // Horizontal scrollable daily cards
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _weeklyForecast!.dailyForecasts.length,
            itemBuilder: (context, index) {
              final dailyForecast = _weeklyForecast!.dailyForecasts[index];
              final dayLabel = index == 0 ? 'Today' : dailyForecast.dayName.substring(0, 3);
              
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 8),
                child: WeatherCard(
                  title: dayLabel,
                  temperature: dailyForecast.temperatureRange,
                  subtitle: dailyForecast.description,
                  additionalInfo: '${dailyForecast.rainChanceString} rain',
                  icon: const Icon(
                    Icons.wb_cloudy,
                    color: AppConstants.accentColor,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Detailed daily list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _weeklyForecast!.dailyForecasts.length,
          itemBuilder: (context, index) {
            final dailyForecast = _weeklyForecast!.dailyForecasts[index];
            final dayLabel = index == 0 ? 'Today' : dailyForecast.dayName;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                collapsedBackgroundColor: AppConstants.primaryColor.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppConstants.accentColor.withOpacity(0.2),
                  child: Text(
                    dailyForecast.dateString.split(' ')[1], // Day number
                    style: const TextStyle(
                      color: AppConstants.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  dayLabel,
                  style: AppConstants.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${dailyForecast.temperatureRange} • ${dailyForecast.description}',
                  style: const TextStyle(
                    color: AppConstants.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  dailyForecast.rainChanceString,
                  style: const TextStyle(
                    color: AppConstants.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailItem('Humidity', '${dailyForecast.humidity}%'),
                        _buildDetailItem('Wind', '${dailyForecast.windSpeed.toStringAsFixed(1)} m/s'),
                        _buildDetailItem('UV Index', '${dailyForecast.uvIndex.toStringAsFixed(1)}'),
                        _buildDetailItem('Sunrise', dailyForecast.sunrise),
                        _buildDetailItem('Sunset', dailyForecast.sunset),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds a detail item for expanded daily forecast
  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppConstants.textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppConstants.secondaryTextColor,
            fontSize: 10,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.update,
                color: AppConstants.secondaryTextColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Last updated: ${_weeklyForecast!.lastUpdatedString}',
                style: const TextStyle(
                  color: AppConstants.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Location: ${_weeklyForecast!.locationName}',
            style: const TextStyle(
              color: AppConstants.secondaryTextColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}