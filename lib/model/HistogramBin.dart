class HistogramBin {
  final String range;
  final int count;

  HistogramBin({
    required this.range,
    required this.count,
  });

  factory HistogramBin.fromJson(Map<String, dynamic> json) {
    return HistogramBin(
      range: json['range'],
      count: json['count'],
    );
  }
}
