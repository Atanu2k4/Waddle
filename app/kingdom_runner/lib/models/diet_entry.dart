class DietEntry {
  final DateTime date;
  final double protein; // in grams
  final double carbs; // in grams

  DietEntry({required this.date, required this.protein, required this.carbs});

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'protein': protein, 'carbs': carbs};
  }

  // Create from JSON
  factory DietEntry.fromJson(Map<String, dynamic> json) {
    return DietEntry(
      date: DateTime.parse(json['date']),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );
  }

  String get dateFormatted {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
