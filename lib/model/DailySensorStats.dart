class DailySensorStats {
  final DateTime date;
  final double average;
  final double min;
  final double max;

  DailySensorStats({
    required this.date,
    required this.average,
    required this.min,
    required this.max,
  });

  factory DailySensorStats.fromJson(Map<String, dynamic> json) {
    return DailySensorStats(
      date: DateTime.parse(json['date']),
      average: (json['average'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }
}
