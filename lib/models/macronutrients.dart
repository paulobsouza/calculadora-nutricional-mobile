/// Modelo para representar os macronutrientes de um alimento
class Macronutrients {
  final double protein; // Proteína em gramas
  final double carbs; // Carboidratos em gramas
  final double fat; // Gordura em gramas
  final double fiber; // Fibra em gramas
  final double sugar; // Açúcar em gramas

  const Macronutrients({
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
  });

  /// Macronutrientes zerados
  factory Macronutrients.zero() =>
      const Macronutrients(protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0);

  /// Converte de Map (Firebase/JSON)
  factory Macronutrients.fromMap(Map<String, dynamic> map) {
    return Macronutrients(
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
      fiber: (map['fiber'] ?? 0).toDouble(),
      sugar: (map['sugar'] ?? 0).toDouble(),
    );
  }

  /// Converte para Map (Firebase/JSON)
  Map<String, dynamic> toMap() {
    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
    };
  }

  /// Calcula calorias a partir dos macros (4 kcal/g proteína, 4 kcal/g carbs, 9 kcal/g gordura)
  int get calculatedCalories {
    return ((protein * 4) + (carbs * 4) + (fat * 9)).round();
  }

  /// Soma dois Macronutrients
  Macronutrients operator +(Macronutrients other) {
    return Macronutrients(
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
    );
  }

  /// Aplica uma quantidade (multiplica pelos gramas consumidos / 100)
  Macronutrients applyPortion(double grams) {
    final factor = grams / 100;
    return Macronutrients(
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
    );
  }

  @override
  String toString() {
    return 'P: ${protein.toStringAsFixed(1)}g | C: ${carbs.toStringAsFixed(1)}g | G: ${fat.toStringAsFixed(1)}g';
  }
}
