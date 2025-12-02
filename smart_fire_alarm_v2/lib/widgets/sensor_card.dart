import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isAlert; // true if alert, false otherwise

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = Colors.blue,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isAlert
            ? AppColors.danger.withValues(alpha: 0.1)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isAlert ? Border.all(color: AppColors.danger, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: isAlert ? AppColors.danger : iconColor),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isAlert ? AppColors.danger : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
