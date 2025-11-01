import 'package:flutter/material.dart';
import 'package:weather_app/Core/constants/api_constants.dart';
import 'dart:async';
import '../../data/models/city_model.dart';
import '../../data/repositories/city_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/neumorphic_card.dart';
import '../widgets/city_list_item.dart';

class SearchScreen extends StatefulWidget {
  final Function(CityModel)? onCitySelected;
  final CityModel? selectedCity;
  final VoidCallback onToggleTheme;
  
  const SearchScreen({
    Key? key,
    this.onCitySelected,
    this.selectedCity,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCityLoading = false;
  String _errorMessage = '';
  List<CityModel> _filteredCities = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filteredCities = [];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _filteredCities = [];
        _isCityLoading = false;
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isCityLoading = true;
      _errorMessage = '';
    });

    _debounce = Timer(Duration(milliseconds: ApiConstants.debounceDelayMs), () async {
      try {
        final cities = await CityRepository.searchCities(query);
        if (mounted) {
          setState(() {
            _filteredCities = cities;
            _isCityLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = AppConstants.errorCityFetch;
            _isCityLoading = false;
            _filteredCities = [];
          });
        }
      }
    });
  }

  void _onCitySelected(CityModel city) {
    _searchController.text = city.displayName;
    setState(() {
      _filteredCities = [];
      _errorMessage = '';
    });
    if (widget.onCitySelected != null) {
      widget.onCitySelected!(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header section with theme toggle
            _buildHeader(),
            // Search field
            _buildSearchField(),
            const SizedBox(height: 16),
            // Selected city display
            if (widget.selectedCity != null) _buildSelectedCityDisplay(),
            // Loading indicator
            if (_isCityLoading) const LoadingWidget(message: 'Searching cities...'),
            // Error message
            if (_errorMessage.isNotEmpty) 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppErrorWidget(
                  message: _errorMessage,
                  onRetry: () => _filterCities(_searchController.text),
                ),
              ),
            // Cities list or empty state
            if (_filteredCities.isEmpty && !_isCityLoading && _searchController.text.isEmpty)
              _buildEmptyState(),
            if (_filteredCities.isNotEmpty && !_isCityLoading)
              _buildCitiesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.pickLocationTitle,
                      style: AppConstants.getTitleStyle(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.pickLocationSubtitle,
                      style: AppConstants.getSubtitleStyle(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              NeumorphicCard(
                onTap: widget.onToggleTheme,
                padding: const EdgeInsets.all(12),
                borderRadius: 12,
                child: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: AppConstants.getPrimaryColor(context),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: NeumorphicCard(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: TextField(
          controller: _searchController,
          onChanged: _filterCities,
          style: AppConstants.getBodyStyle(context),
          decoration: InputDecoration(
            labelText: AppConstants.searchHint,
            labelStyle: TextStyle(color: AppConstants.getSecondaryTextColor(context)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppConstants.getPrimaryColor(context),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppConstants.getSecondaryTextColor(context),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _filterCities('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCityDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: NeumorphicCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: AppConstants.getPrimaryColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Location',
                    style: TextStyle(
                      color: AppConstants.getSecondaryTextColor(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.selectedCity!.displayName,
                    style: AppConstants.getBodyStyle(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppConstants.getPrimaryColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 80,
              color: AppConstants.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Search for Cities',
            style: AppConstants.getTitleStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Enter a city name to find weather information',
              style: AppConstants.getSubtitleStyle(context),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitiesList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: _filteredCities.length,
          itemBuilder: (context, index) {
            final city = _filteredCities[index];
            return CityListItem(
              city: city,
              onTap: () => _onCitySelected(city),
            );
          },
        ),
      ),
    );
  }
}