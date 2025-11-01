# 🌤️ Weather App - Flutter

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow?style=for-the-badge)

**A beautiful and intuitive weather application built with Flutter**

[Features](#-features) • [Screenshots](#-screenshots) • [Getting Started](#-getting-started) • [Architecture](#-project-architecture) • [APIs Used](#-apis-used) • [Roadmap](#-roadmap)

</div>

---

## 📱 Screenshots

> **Add the following screenshots to showcase your app:**

### 1. Search Page - Initial State
**Screenshot:** `screenshots/01_search_initial.png`
- Shows the "Pick Location" screen
- Search bar with placeholder text
- Empty state before user input

### 2. Search Page - City Suggestions
**Screenshot:** `screenshots/02_search_suggestions.png`
- User typing in search bar (e.g., "London")
- List of city suggestions with country flags 🇬🇧
- Latitude and Longitude displayed for each city

### 3. Search Page - Loading State
**Screenshot:** `screenshots/03_search_loading.png`
- Circular progress indicator while fetching cities
- Shows debouncing in action

### 4. Home Page - Weather Display
**Screenshot:** `screenshots/04_home_weather.png`
- Current temperature displayed
- Selected city weather information

### 5. Bottom Navigation Bar
**Screenshot:** `screenshots/05_bottom_nav.png`
- Shows all three tabs: Search, Home, Settings
- Highlight the selected tab with amber accent color

### 6. Error State
**Screenshot:** `screenshots/06_error_state.png`
- Error message displayed when API fails
- User-friendly error handling

---

## ✨ Features

### 🎯 Current Features (v0.1)

- ✅ **City Search with Autocomplete**
  - Real-time city search with debouncing (500ms delay)
  - Displays up to 10 city suggestions
  - Shows country emoji flags 🌍
  - Displays latitude and longitude coordinates

- ✅ **Weather Information**
  - Fetches current temperature on city selection
  - Temperature displayed in Celsius (°C)
  - Smooth navigation to weather details

- ✅ **Bottom Navigation**
  - Three-tab navigation system
  - Search, Home, and Settings tabs
  - Amber accent for selected tab

- ✅ **Loading & Error States**
  - Separate loading indicators for city and weather APIs
  - User-friendly error messages
  - Graceful error handling

- ✅ **Smart UX Features**
  - Auto-clear previous weather on new search
  - Debounced API calls to reduce server load
  - Empty state handling

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK:** >= 3.0.0
- **Dart SDK:** >= 3.0.0
- **IDE:** Android Studio, VS Code, or IntelliJ IDEA
- **APIs:** Active API keys for weather services

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/weather-app.git
   cd weather-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**
   - Open `weather_api.dart`
   - Replace the OpenWeatherMap API key with your own:
     ```dart
     appid=YOUR_API_KEY_HERE
     ```
   - Open `city_api.dart`
   - Replace the GeoNames username with your own:
     ```dart
     username=YOUR_USERNAME_HERE
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📂 Project Architecture

### Current Structure (v0.1)
```
lib/
├── main.dart              # App entry point, bottom navigation setup
├── search_page.dart       # City search screen with autocomplete
├── home_page.dart         # Weather display screen
├── city_api.dart          # GeoNames API integration
└── weather_api.dart       # OpenWeatherMap API integration
```

### 🎯 Planned Structure (v1.0 - Upcoming)
```
lib/
├── main.dart
├── core/
│   ├── constants/         # App constants, API keys
│   ├── utils/            # Helper functions, extensions
│   └── theme/            # App theme, colors, text styles
├── data/
│   ├── models/           # Data models (City, Weather)
│   ├── repositories/     # Data repositories
│   └── services/         # API services
└── presentation/
    ├── screens/          # UI screens
    │   ├── search/
    │   ├── home/
    │   └── settings/
    ├── widgets/          # Reusable widgets
    └── providers/        # State management (Provider/Riverpod)
```

---

## 🌐 APIs Used

### 1. **GeoNames API** (City Search)
- **Endpoint:** `http://api.geonames.org/searchJSON`
- **Purpose:** Search cities by name
- **Features:**
  - Returns city name, country, coordinates
  - Maximum 10 results per query
- **Documentation:** [GeoNames.org](http://www.geonames.org/export/web-services.html)

### 2. **OpenWeatherMap API** (Weather Data)
- **Endpoint:** `https://api.openweathermap.org/data/2.5/weather`
- **Purpose:** Fetch current weather data
- **Features:**
  - Temperature in Celsius
  - Weather conditions, humidity, wind speed (expandable)
- **Documentation:** [OpenWeatherMap.org](https://openweathermap.org/api)

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **State Management** | StatefulWidget (migrating to Provider/Riverpod) |
| **HTTP Client** | http package |
| **Navigation** | Flutter Navigator 2.0 |
| **UI Components** | Material Design 3 |

---

## 🗺️ Roadmap

### ✅ Phase 1: Basic Functionality (Current)
- [x] City search with GeoNames API
- [x] Basic weather display
- [x] Bottom navigation structure
- [x] Loading and error states

### 🚧 Phase 2: Architecture Refactoring (In Progress)
- [ ] Implement clean architecture (core/data/presentation)
- [ ] Add state management (Provider/Riverpod/Bloc)
- [ ] Separate concerns (repositories, services)
- [ ] Create reusable widget library

### 📋 Phase 3: Enhanced Weather Features (Planned)
- [ ] **Detailed Weather Display**
  - Current conditions with icon
  - "Feels like" temperature
  - Humidity, wind speed, pressure
  - Sunrise/sunset times
  
- [ ] **Hourly Forecast**
  - Next 48 hours forecast
  - Temperature graph/chart
  - Precipitation probability
  
- [ ] **Daily Forecast**
  - 7-day forecast
  - High/low temperatures
  - Weather conditions
  
- [ ] **Weekly Overview**
  - Extended forecast visualization
  - Weather trends

### 📋 Phase 4: Advanced Features (Future)
- [ ] **Multiple Location Support**
  - Save favorite cities
  - Quick switch between locations
  
- [ ] **Location Services**
  - Auto-detect current location
  - GPS integration
  
- [ ] **Settings Screen**
  - Toggle temperature units (°C/°F)
  - Change theme (light/dark mode)
  - Notification preferences
  
- [ ] **Offline Support**
  - Cache weather data
  - Offline mode with last fetched data
  
- [ ] **Weather Alerts**
  - Push notifications for severe weather
  - Custom alert preferences

### 📋 Phase 5: Polish & Optimization
- [ ] Animations and transitions
- [ ] Performance optimization
- [ ] Unit and widget testing
- [ ] CI/CD pipeline
- [ ] App store deployment

---

## 📊 Current Data Models

### City Model
```dart
class City {
  final String name;           // City name
  final String Countryname;    // Full country name
  final String countryCode;    // ISO country code (for emoji)
  final double lat;            // Latitude
  final double lng;            // Longitude
}
```

### Weather Model
```dart
class Weather {
  final String temperature;    // Temperature in Celsius
  // More fields to be added: humidity, windSpeed, condition, etc.
}
```

---

## 🎨 Design Philosophy

- **Clean & Modern UI:** Material Design 3 principles
- **Dark Theme:** Eye-friendly dark mode by default
- **Intuitive Navigation:** Bottom navigation for easy access
- **Smooth Interactions:** Loading states and error handling
- **Performance First:** Debounced searches, optimized API calls

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact & Support

- **Developer:** [Your Name]
- **Email:** your.email@example.com
- **GitHub:** [@yourusername](https://github.com/yourusername)
- **Issues:** [Report a bug](https://github.com/yourusername/weather-app/issues)

---

## 🙏 Acknowledgments

- [OpenWeatherMap](https://openweathermap.org/) for weather data API
- [GeoNames](http://www.geonames.org/) for city search API
- [Flutter](https://flutter.dev/) team for the amazing framework
- [Material Design](https://m3.material.io/) for design guidelines

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star this repo if you find it helpful!

</div>