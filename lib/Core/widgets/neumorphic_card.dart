import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class NeumorphicCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool isPressed;
  
  const NeumorphicCard({
    Key? key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.isPressed = false,
  }) : super(key: key);

  @override
  State<NeumorphicCard> createState() => _NeumorphicCardState();
}

class _NeumorphicCardState extends State<NeumorphicCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppConstants.getCardColor(context);
    
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap!();
      } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isPressed || widget.isPressed
              ? _getInnerShadow(isDark)
              : _getOuterShadow(isDark),
        ),
        child: widget.child,
      ),
    );
  }

  List<BoxShadow> _getOuterShadow(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(8, 8),
          blurRadius: 15,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          offset: const Offset(-8, -8),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.grey.shade400.withOpacity(0.5),
          offset: const Offset(8, 8),
          blurRadius: 15,
          spreadRadius: 1,
        ),
        const BoxShadow(
          color: Colors.white,
          offset: Offset(-8, -8),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ];
    }
  }

  List<BoxShadow> _getInnerShadow(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(4, 4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          offset: const Offset(-4, -4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.grey.shade400.withOpacity(0.5),
          offset: const Offset(4, 4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        const BoxShadow(
          color: Colors.white,
          offset: Offset(-4, -4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];
    }
  }
}

class GradientNeumorphicCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  
  const GradientNeumorphicCard({
    Key? key,
    required this.child,
    required this.gradientColors,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              offset: const Offset(0, 10),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
