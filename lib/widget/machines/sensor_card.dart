import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/constants/colors.dart';

class SensorCard extends StatelessWidget {
  final String label, value, unit;
  final bool? alertUp;

  const SensorCard({
    required this.label,
    required this.value,
    required this.unit,
    this.alertUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(" $unit", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 24, // fixed height space for icon (same as icon height)
                child: alertUp != null
                    ? Icon(
                  alertUp! ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: alertUp! ? textGreen : textRed,
                  size: 24,
                )
                    : const SizedBox(), // empty widget with same height
              ),
            ],
          ),
        ],
      ),
    );
  }
}
