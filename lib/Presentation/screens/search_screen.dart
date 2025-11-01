import 'package:flutter/material.dart';
import 'package:weather_app/Core/constants/api_constants.dart';
import 'dart:async';
import '../../data/models/city_model.dart';
import '../../data/repositories/city_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../widgets/city_list_item.dart';

/// Search Screen - Handles city search functionality
/// This screen allows users to search for cities and select one for weather data
class SearchScreen extends StatefulWidget {
  final Function(CityModel)? onCitySelected; // Callback when city is selected
  final CityModel? selectedCity;             // Currently selected city
  
  const SearchScreen({
    Key? key,
    this.onCitySelected,
    this.selectedCity,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Controllers and state variables
  final TextEditingController _searchController = TextEditingController();
  
  // State variables
  bool _isCityLoading = false;        // Tracks if City API call is in progress
  String _errorMessage = '';          // Stores error messages
  List<CityModel> _filteredCities = []; // Stores cities from API response
  Timer? _debounce;                   // Timer for debouncing API calls
  
  @override
  void initState() {
    super.initState();
    // Initialize with empty list
    _filteredCities = [];
  }

  @override
  void dispose() {
    // Cancel any active timer to prevent memory leaks
    _debounce?.cancel();
    // Dispose the text controller
    _searchController.dispose();
    super.dispose();
  }

  /// Filters cities based on search query with debouncing
  void _filterCities(String query) {
    // Cancel any active timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Handle empty query
    if (query.isEmpty) {
      setState(() {
        _filteredCities = [];
        _isCityLoading = false;
        _errorMessage = '';
      });
      return;
    }

    // Set loading state
    setState(() {
      _isCityLoading = true;
      _errorMessage = '';
    });

    // Debounce the API call
    _debounce = Timer(Duration(milliseconds: ApiConstants.debounceDelayMs), () async {
      try {
        // Call repository to search cities
        final cities = await CityRepository.searchCities(query);
        
        // Update UI with results
        if (mounted) {
          setState(() {
            _filteredCities = cities;
            _isCityLoading = false;
          });
        }
      } catch (e) {
        // Handle errors
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

  /// Handles city selection
  void _onCitySelected(CityModel city) {
    // Update search field with selected city
    _searchController.text = city.displayName;
    
    // Clear the city list
    setState(() {
      _filteredCities = [];
      _errorMessage = '';
    });
    
    // Call the callback if provided
    if (widget.onCitySelected != null) {
      widget.onCitySelected!(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            _buildHeader(),
            
            // Search field
            _buildSearchField(),
            
            const SizedBox(height: 16),
            
            // Selected city display
            if (widget.selectedCity != null) _buildSelectedCityDisplay(),
            
            // Loading indicator
            if (_isCityLoading) 
              const LoadingWidget(message: 'Searching cities...'),
            
            // Error message
            if (_errorMessage.isNotEmpty)
              AppErrorWidget(
                message: _errorMessage,
                onRetry: () => _filterCities(_searchController.text),
              ),
            
            // Cities list
            if (_filteredCities.isNotEmpty && !_isCityLoading)
              _buildCitiesList(),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with title and subtitle
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            AppConstants.pickLocationTitle,
            style: AppConstants.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.pickLocationSubtitle,
            style: AppConstants.subtitleTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the search text field
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterCities,
        style: AppConstants.bodyTextStyle,
        decoration: InputDecoration(
          labelText: AppConstants.searchHint,
          labelStyle: const TextStyle(color: AppConstants.secondaryTextColor),
          prefixIcon: const Icon(
            Icons.location_on,
            color: AppConstants.accentColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppConstants.secondaryTextColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _filterCities('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConstants.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConstants.accentColor, width: 2),
          ),
          filled: true,
          fillColor: AppConstants.primaryColor.withOpacity(0.1),
        ),
      ),
    );
  }

  /// Builds the selected city display
  Widget _buildSelectedCityDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: AppConstants.accentColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Location:',
                  style: TextStyle(
                    color: AppConstants.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.selectedCity!.displayName,
                  style: const TextStyle(
                    color: AppConstants.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the cities list
  Widget _buildCitiesList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredCities.length,
        itemBuilder: (context, index) {
          final city = _filteredCities[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CityListItem(
              city: city,
              onTap: () => _onCitySelected(city),
            ),
          );
        },
      ),
    );
  }
}