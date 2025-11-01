import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppConstants.errorColor.withOpacity(0.1),
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              color: AppConstants.errorColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppConstants.getBodyStyle(context).copyWith(
              color: AppConstants.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
