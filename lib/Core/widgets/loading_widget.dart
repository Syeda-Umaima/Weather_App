import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Loading Widget - Reusable circular progress indicator
/// This widget provides a consistent loading indicator across the app
class LoadingWidget extends StatelessWidget {
  final String? message; // Optional loading message
  final double? size; // Optional size for the progress indicator
  
  const LoadingWidget({
    Key? key,
    this.message,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress indicator
          SizedBox(
            width: size ?? 24,
            height: size ?? 24,
            child: CircularProgressIndicator(
              color: AppConstants.accentColor,
              strokeWidth: 2,
            ),
          ),
          
          // Optional loading message
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: AppConstants.bodyTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}