import 'package:flutter/material.dart';
import '../../data/models/city_model.dart';
import '../../data/models/weekly_weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/animated_weather_icon.dart';
import '../../core/widgets/neumorphic_card.dart';
import '../../core/utils/country_helper.dart';
import '../widgets/weather_card.dart';

class WeeklyScreen extends StatefulWidget {
  final CityModel? selectedCity;
  
  const WeeklyScreen({
    Key? key,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  WeeklyWeatherModel? _weeklyForecast;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCity != null) {
      _loadWeeklyForecast();
    }
  }

  @override
  void didUpdateWidget(WeeklyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCity != oldWidget.selectedCity && widget.selectedCity != null) {
      _loadWeeklyForecast();
    }
  }

  Future<void> _loadWeeklyForecast() async {
    if (widget.selectedCity == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
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

  Future<void> _onRefresh() async {
    await _loadWeeklyForecast();
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
                  else if (_weeklyForecast != null) _buildWeeklyContent()
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
          'Weekly Forecast',
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
            'Please search and select a city to view weekly forecast.',
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
        message: 'Loading weekly forecast...',
        size: 48,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: AppErrorWidget(
        message: _errorMessage,
        onRetry: _loadWeeklyForecast,
        icon: Icons.date_range_rounded,
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
              Icons.date_range_rounded,
              size: 64,
              color: AppConstants.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Weekly Data',
            style: AppConstants.getTitleStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadWeeklyForecast,
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

  Widget _buildWeeklyContent() {
    if (_weeklyForecast == null) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week summary
        _buildWeekSummary(),
        const SizedBox(height: 24),
        // Weekly statistics
        _buildWeeklyStatistics(),
        const SizedBox(height: 24),
        // Daily breakdown
        _buildDailyBreakdown(),
        const SizedBox(height: 24),
        // Last updated info
        _buildLastUpdatedInfo(),
      ],
    );
  }

  Widget _buildWeekSummary() {
    final todayForecast = _weeklyForecast!.todayForecast;
    final tomorrowForecast = _weeklyForecast!.tomorrowForecast;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Week Summary',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        
        // Today and Tomorrow cards
        Row(
          children: [
            if (todayForecast != null) 
              Expanded(
                child: _buildSummaryCard(
                  'Today',
                  todayForecast.temperatureRange,
                  todayForecast.description,
                  getWeatherType(todayForecast.description),
                ),
              ),
            if (todayForecast != null && tomorrowForecast != null) 
              const SizedBox(width: 16),
            if (tomorrowForecast != null)
              Expanded(
                child: _buildSummaryCard(
                  'Tomorrow',
                  tomorrowForecast.temperatureRange,
                  tomorrowForecast.description,
                  getWeatherType(tomorrowForecast.description),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Week temperature range
        Container(
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.thermostat_rounded,
                  color: AppConstants.getPrimaryColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week Temperature Range',
                        style: TextStyle(
                          color: AppConstants.getTextColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_weeklyForecast!.weekHighestTemp} / ${_weeklyForecast!.weekLowestTemp}',
                        style: TextStyle(
                          color: AppConstants.getTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'High / Low for the week • Avg Humidity: ${_weeklyForecast!.averageHumidity.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: AppConstants.getSecondaryTextColor(context),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String temperature, String description, WeatherType weatherType) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(weatherType),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors(weatherType).first.withOpacity(0.3),
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
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temperature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedWeatherIcon(
                  weatherType: weatherType,
                  size: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Statistics',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        _buildStatisticsGrid(),
      ],
    );
  }

  Widget _buildStatisticsGrid() {
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
            _buildWeeklyGridCard(
              'Forecast Days',
              '${_weeklyForecast!.forecastDaysCount}',
              'Days available',
              Icons.calendar_today_rounded,
            ),
            _buildWeeklyGridCard(
              'Avg Humidity',
              '${_weeklyForecast!.averageHumidity.toStringAsFixed(1)}%',
              'Week average',
              Icons.water_drop_rounded,
            ),
            _buildWeeklyGridCard(
              'Week High',
              _weeklyForecast!.weekHighestTemp,
              'Maximum temp',
              Icons.arrow_upward_rounded,
              iconColor: Colors.red,
            ),
            _buildWeeklyGridCard(
              'Week Low',
              _weeklyForecast!.weekLowestTemp,
              'Minimum temp',
              Icons.arrow_downward_rounded,
              iconColor: Colors.blue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyGridCard(String title, String value, String subtitle, IconData icon, {Color? iconColor}) {
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
              color: iconColor ?? AppConstants.getPrimaryColor(context),
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
            const SizedBox(height: 2),
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
        ),
      ),
    );
  }

  Widget _buildDailyBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Breakdown',
          style: AppConstants.getTitleStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        
        // Horizontal scrollable daily cards
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _weeklyForecast!.dailyForecasts.length,
            itemBuilder: (context, index) {
              final dailyForecast = _weeklyForecast!.dailyForecasts[index];
              final weatherType = getWeatherType(dailyForecast.description);
              final dayLabel = index == 0 ? 'Today' : dailyForecast.dayName.substring(0, 3);
              
              return Container(
                width: 140,
                margin: EdgeInsets.only(
                  right: index < _weeklyForecast!.dailyForecasts.length - 1 ? 12 : 0,
                ),
                child: _buildDailyCard(
                  dayLabel,
                  dailyForecast.temperatureRange,
                  dailyForecast.description,
                  '${dailyForecast.rainChanceString} rain',
                  weatherType,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Detailed daily list
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Forecast',
              style: AppConstants.getTitleStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildDetailedDailyList(),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyCard(String title, String temperature, String subtitle, String additionalInfo, WeatherType weatherType) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(weatherType),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors(weatherType).first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temperature,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Text(
              additionalInfo,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedDailyList() {
    return Column(
      children: _weeklyForecast!.dailyForecasts.map((dailyForecast) {
        final index = _weeklyForecast!.dailyForecasts.indexOf(dailyForecast);
        final weatherType = getWeatherType(dailyForecast.description);
        final dayLabel = index == 0 ? 'Today' : dailyForecast.dayName;
        
        return Container(
          margin: EdgeInsets.only(bottom: index < _weeklyForecast!.dailyForecasts.length - 1 ? 12 : 0),
          decoration: BoxDecoration(
            color: AppConstants.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: const Border(),
            collapsedShape: const Border(),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                dailyForecast.dateString.split(' ')[1],
                style: TextStyle(
                  color: AppConstants.getPrimaryColor(context),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              dayLabel,
              style: AppConstants.getBodyStyle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${dailyForecast.temperatureRange} • ${dailyForecast.description}',
              style: TextStyle(
                color: AppConstants.getSecondaryTextColor(context),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              dailyForecast.rainChanceString,
              style: TextStyle(
                color: AppConstants.getPrimaryColor(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
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
      }).toList(),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.getPrimaryColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppConstants.getTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppConstants.getSecondaryTextColor(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedInfo() {
    return NeumorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.update_rounded,
                color: AppConstants.getSecondaryTextColor(context),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Last updated: ${_weeklyForecast!.lastUpdatedString}',
                style: TextStyle(
                  color: AppConstants.getSecondaryTextColor(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Location: ${_weeklyForecast!.locationName}',
            style: TextStyle(
              color: AppConstants.getSecondaryTextColor(context),
              fontSize: 10,
            ),
          ),
        ],
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