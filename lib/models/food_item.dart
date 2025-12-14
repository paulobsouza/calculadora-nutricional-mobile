import 'macronutrients.dart';

class FoodItem {
  final String id;
  final String name;
  final int calories;
  final DateTime date;
  final double portionGrams; // Quantidade em gramas
  final Macronutrients macros; // Macronutrientes
  final String? fdcId; // ID do alimento na API USDA (opcional)

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
    this.portionGrams = 100,
    required this.macros,
    this.fdcId,
  });

  // Factory para converter JSON do Firebase em Objeto
  factory FoodItem.fromMap(String id, Map<String, dynamic> map) {
    return FoodItem(
      id: id,
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      date: map['date'].toDate(),
      portionGrams: (map['portionGrams'] ?? 100).toDouble(),
      macros: map['macros'] != null
          ? Macronutrients.fromMap(map['macros'] as Map<String, dynamic>)
          : Macronutrients.zero(),
      fdcId: map['fdcId'],
    );
  }

  // Converte para Map (Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'date': date,
      'portionGrams': portionGrams,
      'macros': macros.toMap(),
      'fdcId': fdcId,
    };
  }

  /// Retorna uma string formatada dos macros
  String get macrosFormatted => macros.toString();
}
