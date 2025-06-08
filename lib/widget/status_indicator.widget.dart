import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final double width;
  final double height;
  final double iconSize;
  final double textSize;

  const StatusIndicator({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor = Colors.green,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.width = 100,
    this.height = 30,
    this.iconSize = 16,
    this.textSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
            ),
          ),
        ],
      ),
    );
  }
}