import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/constants/colors.dart';
import 'package:maintenance_platform_frontend/widget/machines/progress_bar.widget.dart';


class InfoCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData? icon;
  final Color? iconColor;

  final bool showProgress;
  final double progress;
  final double progressBarHeight;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.showProgress = false,
    this.progress = 0.0,
    this.progressBarHeight = 6.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Same width logic as SensorCard
    double cardWidth = (MediaQuery.of(context).size.width - 52) / 2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 12, color: iconColor),
              Text(
                " $value",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: progressBarHeight,
            child: showProgress
                ? ProgressBar(
              width: double.infinity,
              height: progressBarHeight,
              progress: progress.clamp(0.0, 1.0),
            )
                : const SizedBox(), // empty to preserve space
          ),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          // Always reserve space for progress bar
        ],
      ),
    );
  }
}
