import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;
  final double? size;
  
  const LoadingWidget({
    Key? key,
    this.message,
    this.size,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Container(
                  width: widget.size ?? 40,
                  height: widget.size ?? 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.getPrimaryColor(context),
                        AppConstants.getAccentColor(context),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.getPrimaryColor(context).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.getBackgroundColor(context),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: AppConstants.getBodyStyle(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
