import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/models/daily_weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/animated_weather_icon.dart';
import '../../core/widgets/neumorphic_card.dart';
import '../../core/utils/country_helper.dart';
import '../widgets/weather_card.dart';

class DailyScreen extends StatefulWidget {
  final CityModel? selectedCity;
  
  const DailyScreen({
    Key? key,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
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
      if (mounted) {
        setState(() {
          _dailyForecasts = forecasts;
          _isLoading = false;
          _selectedDayIndex = 0;
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

  Future<void> _onRefresh() async {
    await _loadDailyForecast();
  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.getBackgroundColor(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppConstants.getPrimaryColor(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  if (widget.selectedCity == null) _buildNoCitySelected()
                  else if (_isLoading) _buildLoadingState()
                  else if (_errorMessage.isNotEmpty) _buildErrorState()
                  else if (_dailyForecasts.isNotEmpty) _buildDailyContent()
                  else _buildNoDataState(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Forecast',
          style: AppConstants.getTitleStyle(context),
        ),
        if (widget.selectedCity != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                CountryHelper.countryCodeToEmoji(widget.selectedCity!.countryCode),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.selectedCity!.displayName,
                  style: AppConstants.getSubtitleStyle(context),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNoCitySelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConstants.getPrimaryColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_rounded,
              size: 64,
              color: AppConstants.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Location Selected',
            style: AppConstants.getTitleStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Please search and select a city to view daily forecast.',
            style: AppConstants.getSubtitleStyle(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(
        message: 'Loading daily forecast...',
        size: 48,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadDailyForecast,
        icon: Icons.today_rounded,
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConstants.getPrimaryColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.today_rounded,
              size: 64,
              color: AppConstants.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Daily Data',
            style: AppConstants.getTitleStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadDailyForecast,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.getPrimaryColor(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
            ),
            child: const Text('Load Forecast'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal day selector
        _buildDaySelector(),
        const SizedBox(height: 24),
        // Selected day details
        if (_selectedDayIndex < _dailyForecasts.length) _buildSelectedDayDetails(),
        const SizedBox(height: 24),
        // Daily overview list
        _buildDailyOverview(),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next ${_dailyForecasts.length} Days',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dailyForecasts.length,
            itemBuilder: (context, index) {
              final forecast = _dailyForecasts[index];
              final weatherType = getWeatherType(forecast.description);
              final dayLabel = index == 0 ? 'Today' : forecast.dayName.substring(0, 3);
              
              return CompactWeatherCard(
                time: dayLabel,
                temperature: forecast.temperatureRange,
                description: forecast.description,
                isSelected: index == _selectedDayIndex,
                icon: AnimatedWeatherIcon(
                  weatherType: weatherType,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDayDetails() {
    final selectedForecast = _dailyForecasts[_selectedDayIndex];
    final weatherType = getWeatherType(selectedForecast.description);
    final dayLabel = _selectedDayIndex == 0 ? 'Today' : selectedForecast.dayName;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Forecast - $dayLabel',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        
        // Main weather card for selected day
        GradientNeumorphicCard(
          gradientColors: _getGradientColors(weatherType),
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedForecast.temperatureRange,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedForecast.description.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  AnimatedWeatherIcon(
                    weatherType: weatherType,
                    size: 70,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem('High', '${selectedForecast.maxTemperature}°C'),
                    _buildDetailItem('Low', '${selectedForecast.minTemperature}°C'),
                    _buildDetailItem('Rain', selectedForecast.rainChanceString),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Details grid for selected day
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Details',
              style: AppConstants.getTitleStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildDetailsGrid(selectedForecast),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Sunrise and sunset
        _buildSunriseSunset(selectedForecast),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(DailyWeatherModel selectedForecast) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth > 400 ? 1.4 : 1.2,
          children: [
            _buildDailyGridCard(
              'Humidity',
              '${selectedForecast.humidity}%',
              Icons.water_drop_rounded,
            ),
            _buildDailyGridCard(
              'Wind Speed',
              '${selectedForecast.windSpeed.toStringAsFixed(1)} m/s',
              Icons.air_rounded,
            ),
            _buildDailyGridCard(
              'Rain Chance',
              selectedForecast.rainChanceString,
              Icons.grain_rounded,
            ),
            _buildDailyGridCard(
              'UV Index',
              selectedForecast.uvIndex.toStringAsFixed(1),
              Icons.wb_sunny_rounded,
              subtitle: selectedForecast.uvIndexDescription,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDailyGridCard(String title, String value, IconData icon, {String? subtitle}) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppConstants.getPrimaryColor(context),
              size: 20,
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: AppConstants.getSecondaryTextColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: AppConstants.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: AppConstants.getSecondaryTextColor(context),
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSunriseSunset(DailyWeatherModel forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sun & Moon',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSunCard(
                'Sunrise',
                forecast.sunrise,
                Icons.wb_sunny_rounded,
                [const Color(0xFFFFD93D), const Color(0xFFFF9F43)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSunCard(
                'Sunset',
                forecast.sunset,
                Icons.nightlight_rounded,
                [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSunCard(String title, String time, IconData icon, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Overview',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _dailyForecasts.length,
            itemBuilder: (context, index) {
              final forecast = _dailyForecasts[index];
              final weatherType = getWeatherType(forecast.description);
              final dayLabel = index == 0 ? 'Today' : forecast.dayName;
              
              return Container(
                margin: EdgeInsets.only(bottom: index < _dailyForecasts.length - 1 ? 8 : 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppConstants.getPrimaryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        forecast.dateString.split(' ')[1],
                        style: TextStyle(
                          color: AppConstants.getPrimaryColor(context),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: AnimatedWeatherIcon(
                        weatherType: weatherType,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayLabel,
                            style: AppConstants.getBodyStyle(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            forecast.description,
                            style: TextStyle(
                              color: AppConstants.getSecondaryTextColor(context),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          forecast.temperatureRange,
                          style: AppConstants.getBodyStyle(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          forecast.rainChanceString,
                          style: TextStyle(
                            color: AppConstants.getPrimaryColor(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors(WeatherType weatherType) {
    switch (weatherType) {
      case WeatherType.sunny:
        return AppConstants.sunnyGradient;
      case WeatherType.cloudy:
        return AppConstants.cloudyGradient;
      case WeatherType.rainy:
        return AppConstants.rainyGradient;
      case WeatherType.snowy:
        return [const Color(0xFFA8D0E6), const Color(0xFF74B9FF)];
      case WeatherType.stormy:
        return [const Color(0xFF2C3E50), const Color(0xFF4A235A)];
      case WeatherType.night:
        return AppConstants.nightGradient;
      default:
        return AppConstants.cloudyGradient;
    }
  }
}