import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MaintenanceCard extends StatelessWidget {
  final String title, type, date;
  final Color typeColor;
  final Color textColor;

  const MaintenanceCard({
    required this.title,
    required this.type,
    required this.date,
    required this.typeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(type, style: TextStyle(color: textColor)),
            ],
          ),
          Text(date, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}