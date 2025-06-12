class VibrationTrend {
  final DateTime timestamp;
  final double vibrationX;
  final double vibrationY;

  VibrationTrend({
    required this.timestamp,
    required this.vibrationX,
    required this.vibrationY,
  });

  factory VibrationTrend.fromJson(Map<String, dynamic> json) {
    return VibrationTrend(
      timestamp: DateTime.parse(json['timestamp']),
      vibrationX: (json['vibrationX'] ?? 0).toDouble(),
      vibrationY: (json['vibrationY'] ?? 0).toDouble(),
    );
  }
}
