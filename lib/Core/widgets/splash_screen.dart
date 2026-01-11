import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _cloudController;
  late AnimationController _sunController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _cloudOffset;
  late Animation<double> _sunRotation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Cloud animation
    _cloudController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _cloudOffset = Tween<double>(
      begin: -50,
      end: 400,
    ).animate(CurvedAnimation(parent: _cloudController, curve: Curves.linear));

    // Sun rotation
    _sunController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _sunRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_sunController);
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Navigate after splash
    await Future.delayed(const Duration(milliseconds: 2500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _cloudController.dispose();
    _sunController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1F3A),
                    const Color(0xFF252B48),
                    const Color(0xFF1A1F3A),
                  ]
                : [
                    const Color(0xFF87CEEB),
                    const Color(0xFFE8F4FF),
                    const Color(0xFFFFFFFF),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Animated clouds
            ..._buildClouds(isDark),

            // Sun/Moon
            _buildCelestialBody(isDark),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: _buildLogo(isDark),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Animated text
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'Weather App',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppConstants.lightText,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Personal Weather Companion',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white70
                                  : AppConstants.lightSecondaryText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading indicator
                  FadeTransition(
                    opacity: _textOpacity,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark
                              ? AppConstants.darkAccent
                              : AppConstants.lightPrimary,
                        ),
                      ),
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

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF5B9EE1), const Color(0xFF667EEA)]
              : [const Color(0xFFFFD93D), const Color(0xFFFF9F43)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF5B9EE1) : const Color(0xFFFF9F43))
                .withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  List<Widget> _buildClouds(bool isDark) {
    return [
      AnimatedBuilder(
        animation: _cloudOffset,
        builder: (context, child) {
          return Positioned(
            top: 100,
            left: _cloudOffset.value - 100,
            child: _buildCloud(80, isDark ? Colors.white10 : Colors.white70),
          );
        },
      ),
      AnimatedBuilder(
        animation: _cloudOffset,
        builder: (context, child) {
          return Positioned(
            top: 180,
            right: _cloudOffset.value - 150,
            child: _buildCloud(60, isDark ? Colors.white10 : Colors.white60),
          );
        },
      ),
      AnimatedBuilder(
        animation: _cloudOffset,
        child: _buildCloud(70, isDark ? Colors.white10 : Colors.white54),
        builder: (context, child) {
          return Positioned(
            bottom: 200,
            left: _cloudOffset.value,
            child: child!,
          );
        },
      ),
    ];
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

  Widget _buildCelestialBody(bool isDark) {
    return Positioned(
      top: 80,
      right: 40,
      child: AnimatedBuilder(
        animation: _sunRotation,
        builder: (context, child) {
          return Transform.rotate(
            angle: isDark ? 0 : _sunRotation.value * 0.1,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.yellow.withOpacity(0.3),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
              ),
            ),
          );
        },
      ),
    );
  }
}
