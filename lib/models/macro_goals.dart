import 'macronutrients.dart';

/// Modelo para definir metas de macronutrientes do usuário
class MacroGoals {
  final int dailyCalories; // Meta de calorias diárias
  final double proteinPercentage; // Porcentagem de proteína
  final double carbsPercentage; // Porcentagem de carboidratos
  final double fatPercentage; // Porcentagem de gordura

  const MacroGoals({
    required this.dailyCalories,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
  });

  /// Metas padrão (2000 kcal, 30% proteína, 40% carbs, 30% gordura)
  factory MacroGoals.defaultGoals() => const MacroGoals(
    dailyCalories: 2000,
    proteinPercentage: 30,
    carbsPercentage: 40,
    fatPercentage: 30,
  );

  /// Valida se as porcentagens somam 100%
  bool get isValid =>
      (proteinPercentage + carbsPercentage + fatPercentage - 100).abs() < 0.01;

  /// Converte de Map (Firebase)
  factory MacroGoals.fromMap(Map<String, dynamic> map) {
    return MacroGoals(
      dailyCalories: map['dailyCalories'] ?? 2000,
      proteinPercentage: (map['proteinPercentage'] ?? 30).toDouble(),
      carbsPercentage: (map['carbsPercentage'] ?? 40).toDouble(),
      fatPercentage: (map['fatPercentage'] ?? 30).toDouble(),
    );
  }

  /// Converte para Map (Firebase)
  Map<String, dynamic> toMap() {
    return {
      'dailyCalories': dailyCalories,
      'proteinPercentage': proteinPercentage,
      'carbsPercentage': carbsPercentage,
      'fatPercentage': fatPercentage,
    };
  }

  /// Calcula gramas de proteína baseado na meta
  /// Proteína = 4 kcal/g
  double get proteinGrams => (dailyCalories * proteinPercentage / 100) / 4;

  /// Calcula gramas de carboidratos baseado na meta
  /// Carboidrato = 4 kcal/g
  double get carbsGrams => (dailyCalories * carbsPercentage / 100) / 4;

  /// Calcula gramas de gordura baseado na meta
  /// Gordura = 9 kcal/g
  double get fatGrams => (dailyCalories * fatPercentage / 100) / 9;

  /// Retorna as metas em formato de Macronutrients
  Macronutrients get targetMacros =>
      Macronutrients(protein: proteinGrams, carbs: carbsGrams, fat: fatGrams);

  /// Copia com alterações
  MacroGoals copyWith({
    int? dailyCalories,
    double? proteinPercentage,
    double? carbsPercentage,
    double? fatPercentage,
  }) {
    return MacroGoals(
      dailyCalories: dailyCalories ?? this.dailyCalories,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      carbsPercentage: carbsPercentage ?? this.carbsPercentage,
      fatPercentage: fatPercentage ?? this.fatPercentage,
    );
  }

  @override
  String toString() {
    return 'Meta: $dailyCalories kcal | P: ${proteinPercentage.toInt()}% (${proteinGrams.toStringAsFixed(0)}g) | C: ${carbsPercentage.toInt()}% (${carbsGrams.toStringAsFixed(0)}g) | G: ${fatPercentage.toInt()}% (${fatGrams.toStringAsFixed(0)}g)';
  }
}
