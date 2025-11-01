import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Error Widget - Reusable error message display
/// This widget provides a consistent error display across the app
class AppErrorWidget extends StatelessWidget {
  final String message; // Error message to display
  final VoidCallback? onRetry; // Optional retry callback
  final IconData? icon; // Optional error icon
  
  const AppErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Icon(
            icon ?? Icons.error_outline,
            color: AppConstants.errorColor,
            size: 48,
          ),
          
          const SizedBox(height: 12),
          
          // Error message
          Text(
            message,
            style: const TextStyle(
              color: AppConstants.errorColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Optional retry button
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: AppConstants.textColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}