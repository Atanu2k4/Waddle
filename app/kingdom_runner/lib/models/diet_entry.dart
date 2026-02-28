class DietEntry {
  final DateTime date;
  final double protein; // in grams
<<<<<<< HEAD
  final double calories; // in kcal

  DietEntry({
    required this.date,
    required this.protein,
    required this.calories,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'protein': protein,
      'calories': calories,
    };
=======
  final double carbs; // in grams

  DietEntry({required this.date, required this.protein, required this.carbs});

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'protein': protein, 'carbs': carbs};
>>>>>>> 2ed4fecd9227531f19858abaf36a91a6a7fdffe5
  }

  // Create from JSON
  factory DietEntry.fromJson(Map<String, dynamic> json) {
    return DietEntry(
      date: DateTime.parse(json['date']),
      protein: (json['protein'] as num).toDouble(),
<<<<<<< HEAD
      calories: (json['calories'] as num).toDouble(),
=======
      carbs: (json['carbs'] as num).toDouble(),
>>>>>>> 2ed4fecd9227531f19858abaf36a91a6a7fdffe5
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
