import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedWeatherIcon extends StatefulWidget {
  final WeatherType weatherType;
  final double size;
  
  const AnimatedWeatherIcon({
    Key? key,
    required this.weatherType,
    this.size = 80,
  }) : super(key: key);

  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _secondaryController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _secondaryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.linear),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _secondaryController, curve: Curves.easeInOut),
    );
    
    _bounceAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _secondaryController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _buildWeatherIcon(),
    );
  }

  Widget _buildWeatherIcon() {
    switch (widget.weatherType) {
      case WeatherType.sunny:
        return _buildSunnyIcon();
      case WeatherType.cloudy:
        return _buildCloudyIcon();
      case WeatherType.rainy:
        return _buildRainyIcon();
      case WeatherType.snowy:
        return _buildSnowyIcon();
      case WeatherType.stormy:
        return _buildStormyIcon();
      case WeatherType.night:
        return _buildNightIcon();
      default:
        return _buildCloudyIcon();
    }
  }

  Widget _buildSunnyIcon() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.yellow.shade300,
                  Colors.orange.shade400,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloudyIcon() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: widget.size * 0.1,
                top: widget.size * 0.3,
                child: _buildCloud(widget.size * 0.5, Colors.grey.shade400),
              ),
              Positioned(
                right: widget.size * 0.1,
                top: widget.size * 0.1,
                child: _buildCloud(widget.size * 0.4, Colors.grey.shade300),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCloud(double size, Color color) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }

  Widget _buildRainyIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -5),
          child: _buildCloud(widget.size * 0.6, Colors.blueGrey.shade300),
        ),
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _secondaryController,
            builder: (context, child) {
              final offset = (_secondaryController.value * 20) % 20;
              return Transform.translate(
                offset: Offset(
                  (index - 1) * 12,
                  10 + offset,
                ),
                child: Container(
                  width: 2,
                  height: 10,
                  color: Colors.blue.shade400,
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSnowyIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -5),
          child: _buildCloud(widget.size * 0.6, Colors.grey.shade300),
        ),
        ...List.generate(4, (index) {
          return AnimatedBuilder(
            animation: _secondaryController,
            builder: (context, child) {
              final offset = (_secondaryController.value * 25 + index * 8) % 25;
              return Transform.translate(
                offset: Offset(
                  (index - 1.5) * 10,
                  offset,
                ),
                child: Icon(
                  Icons.ac_unit,
                  color: Colors.white,
                  size: 8,
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildStormyIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -8),
          child: _buildCloud(widget.size * 0.7, Colors.grey.shade700),
        ),
        AnimatedBuilder(
          animation: _secondaryController,
          builder: (context, child) {
            return Opacity(
              opacity: _secondaryController.value > 0.5 ? 1.0 : 0.3,
              child: Transform.translate(
                offset: const Offset(0, 8),
                child: Icon(
                  Icons.bolt,
                  color: Colors.yellow.shade600,
                  size: widget.size * 0.3,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNightIcon() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo.shade300,
                  Colors.purple.shade400,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: widget.size * 0.2,
                  top: widget.size * 0.2,
                  child: Container(
                    width: widget.size * 0.6,
                    height: widget.size * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum WeatherType {
  sunny,
  cloudy,
  rainy,
  snowy,
  stormy,
  night,
}

WeatherType getWeatherType(String description) {
  description = description.toLowerCase();
  
  if (description.contains('clear') || description.contains('sunny')) {
    return WeatherType.sunny;
  } else if (description.contains('rain') || description.contains('drizzle')) {
    return WeatherType.rainy;
  } else if (description.contains('snow')) {
    return WeatherType.snowy;
  } else if (description.contains('thunder') || description.contains('storm')) {
    return WeatherType.stormy;
  } else if (description.contains('cloud')) {
    return WeatherType.cloudy;
  } else if (description.contains('night')) {
    return WeatherType.night;
  }
  
  return WeatherType.cloudy;
}