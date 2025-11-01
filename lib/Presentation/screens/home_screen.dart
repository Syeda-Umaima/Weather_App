import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/animated_weather_icon.dart';
import '../../core/widgets/neumorphic_card.dart';
import '../../core/utils/country_helper.dart';
import '../widgets/weather_card.dart';

class HomeScreen extends StatefulWidget {
  final CityModel? selectedCity;
  
  const HomeScreen({
    Key? key,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isWeatherLoading = false;
  String _errorMessage = '';
  WeatherModel? _currentWeather;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCity != null) {
      _loadWeatherData();
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCity != oldWidget.selectedCity && widget.selectedCity != null) {
      _loadWeatherData();
    }
  }

  Future<void> _loadWeatherData() async {
    if (widget.selectedCity == null) return;
    
    setState(() {
      _isWeatherLoading = true;
      _errorMessage = '';
    });

    try {
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

  Future<void> _onRefresh() async {
    await _loadWeatherData();
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
                  else if (_isWeatherLoading) _buildLoadingState()
                  else if (_errorMessage.isNotEmpty) _buildErrorState()
                  else if (_currentWeather != null) _buildWeatherContent()
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
          'Current Weather',
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
            'Please search and select a city to view weather information.',
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
        message: 'Loading weather data...',
        size: 48,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadWeatherData,
        icon: Icons.cloud_off_rounded,
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
              Icons.cloud_off_rounded,
              size: 64,
              color: AppConstants.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Weather Data',
            style: AppConstants.getTitleStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadWeatherData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.getPrimaryColor(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
            ),
            child: const Text('Load Weather'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_currentWeather == null) return const SizedBox();
    
    final weatherType = getWeatherType(_currentWeather!.description);
    
    return Column(
      children: [
        // Main weather card with gradient
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
                        'Now',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentWeather!.temperatureWithUnit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentWeather!.description.toUpperCase(),
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
                    size: 80,
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
                    _buildWeatherDetail('Feels Like', _currentWeather!.feelsLikeString),
                    _buildWeatherDetail('Humidity', '${_currentWeather!.humidity}%'),
                    _buildWeatherDetail('Wind', '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Weather details grid
        Text(
          'Weather Details',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        
        _buildWeatherDetailsGrid(),
        
        const SizedBox(height: 24),
        
        // Last updated info
        NeumorphicCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.update_rounded,
                color: AppConstants.getSecondaryTextColor(context),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                style: TextStyle(
                  color: AppConstants.getSecondaryTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
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

  Widget _buildWeatherDetailsGrid() {
    if (_currentWeather == null) return const SizedBox();
    
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
            _buildWeatherGridCard(
              'Humidity',
              '${_currentWeather!.humidity}%',
              Icons.water_drop_rounded,
            ),
            _buildWeatherGridCard(
              'Wind Speed',
              '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s',
              Icons.air_rounded,
            ),
            _buildWeatherGridCard(
              'Pressure',
              '${_currentWeather!.pressure} hPa',
              Icons.compress_rounded,
            ),
            _buildWeatherGridCard(
              'Feels Like',
              '${_currentWeather!.feelsLike.toStringAsFixed(1)}°C',
              Icons.thermostat_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeatherGridCard(String title, String value, IconData icon) {
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
                  fontSize: 12,
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
          ],
        ),
      ),
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