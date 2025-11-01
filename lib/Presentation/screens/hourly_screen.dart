import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/models/hourly_weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/animated_weather_icon.dart';
import '../../core/widgets/neumorphic_card.dart';
import '../../core/utils/country_helper.dart';
import '../widgets/weather_card.dart';

class HourlyScreen extends StatefulWidget {
  final CityModel? selectedCity;
  
  const HourlyScreen({
    Key? key,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<HourlyScreen> createState() => _HourlyScreenState();
}

class _HourlyScreenState extends State<HourlyScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<HourlyWeatherModel> _hourlyForecasts = [];
  int _selectedHourIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCity != null) {
      _loadHourlyForecast();
    }
  }

  @override
  void didUpdateWidget(HourlyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCity != oldWidget.selectedCity && widget.selectedCity != null) {
      _loadHourlyForecast();
    }
  }

  Future<void> _loadHourlyForecast() async {
    if (widget.selectedCity == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final forecasts = await WeatherRepository.getHourlyForecast(widget.selectedCity!);
      if (mounted) {
        setState(() {
          _hourlyForecasts = forecasts;
          _isLoading = false;
          _selectedHourIndex = 0;
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

  Future<void> _onRefresh() async {
    await _loadHourlyForecast();
  }

  void _onHourSelected(int index) {
    setState(() {
      _selectedHourIndex = index;
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
                  else if (_hourlyForecasts.isNotEmpty) _buildHourlyContent()
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
          'Hourly Forecast',
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
            'Please search and select a city to view hourly forecast.',
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
        message: 'Loading hourly forecast...',
        size: 48,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadHourlyForecast,
        icon: Icons.schedule_rounded,
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
              Icons.schedule_rounded,
              size: 64,
              color: AppConstants.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Hourly Data',
            style: AppConstants.getTitleStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadHourlyForecast,
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

  Widget _buildHourlyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal hour selector
        _buildHourSelector(),
        const SizedBox(height: 24),
        // Selected hour details
        if (_selectedHourIndex < _hourlyForecasts.length) _buildSelectedHourDetails(),
        const SizedBox(height: 24),
        // Next hours overview
        _buildNextHoursOverview(),
      ],
    );
  }

  Widget _buildHourSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next 24 Hours',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hourlyForecasts.length,
            itemBuilder: (context, index) {
              final forecast = _hourlyForecasts[index];
              final weatherType = getWeatherType(forecast.description);
              
              return CompactWeatherCard(
                time: forecast.hourString,
                temperature: forecast.temperatureWithUnit,
                description: forecast.description,
                isSelected: index == _selectedHourIndex,
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

  Widget _buildSelectedHourDetails() {
    final selectedForecast = _hourlyForecasts[_selectedHourIndex];
    final weatherType = getWeatherType(selectedForecast.description);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Forecast - ${selectedForecast.hourString}',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        
        // Main weather card for selected hour
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
                        selectedForecast.hourString,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedForecast.temperatureWithUnit,
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
                    _buildDetailItem('Feels Like', '${selectedForecast.feelsLike.toStringAsFixed(1)}°C'),
                    _buildDetailItem('Humidity', '${selectedForecast.humidity}%'),
                    _buildDetailItem('Rain', selectedForecast.rainChanceString),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Weather details section
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

  Widget _buildDetailsGrid(HourlyWeatherModel selectedForecast) {
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
            _buildHourlyGridCard(
              'Humidity',
              '${selectedForecast.humidity}%',
              Icons.water_drop_rounded,
            ),
            _buildHourlyGridCard(
              'Wind Speed',
              '${selectedForecast.windSpeed.toStringAsFixed(1)} m/s',
              Icons.air_rounded,
            ),
            _buildHourlyGridCard(
              'Rain Chance',
              selectedForecast.rainChanceString,
              Icons.grain_rounded,
            ),
            _buildHourlyGridCard(
              'Feels Like',
              '${selectedForecast.feelsLike.toStringAsFixed(1)}°C',
              Icons.thermostat_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildHourlyGridCard(String title, String value, IconData icon) {
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
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: AppConstants.getSecondaryTextColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: AppConstants.getTextColor(context),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextHoursOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Overview',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _hourlyForecasts.length,
            itemBuilder: (context, index) {
              final forecast = _hourlyForecasts[index];
              final weatherType = getWeatherType(forecast.description);
              
              return Container(
                margin: EdgeInsets.only(bottom: index < _hourlyForecasts.length - 1 ? 8 : 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        forecast.hourString,
                        style: TextStyle(
                          color: AppConstants.getSecondaryTextColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                            forecast.temperatureWithUnit,
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
                          forecast.rainChanceString,
                          style: TextStyle(
                            color: AppConstants.getPrimaryColor(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${forecast.windSpeed.toStringAsFixed(1)} m/s',
                          style: TextStyle(
                            color: AppConstants.getSecondaryTextColor(context),
                            fontSize: 10,
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