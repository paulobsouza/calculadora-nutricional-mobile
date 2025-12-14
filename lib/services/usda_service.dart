import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/macronutrients.dart';

/// Resultado de busca de alimento da API USDA
class USDAFoodResult {
  final String fdcId;
  final String description;
  final String? brandOwner;
  final int calories;
  final Macronutrients macros;

  USDAFoodResult({
    required this.fdcId,
    required this.description,
    this.brandOwner,
    required this.calories,
    required this.macros,
  });

  factory USDAFoodResult.fromJson(Map<String, dynamic> json) {
    // Extrair nutrientes do array foodNutrients
    final nutrients = json['foodNutrients'] as List<dynamic>? ?? [];

    double getNumber(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    double getNutrientValue(List<dynamic> nutrients, List<int> nutrientIds) {
      for (final id in nutrientIds) {
        for (final n in nutrients) {
          final nutrientId = n['nutrientId'] ?? n['nutrient']?['id'];
          if (nutrientId == id) {
            return getNumber(n['value'] ?? n['amount']);
          }
        }
      }
      return 0.0;
    }

    // IDs dos nutrientes USDA:
    // 1008 = Energy (kcal)
    // 1003 = Protein
    // 1005 = Carbohydrate
    // 1004 = Total lipid (fat)
    // 1079 = Fiber
    // 2000 = Sugars

    final calories = getNutrientValue(nutrients, [1008]).round();
    final protein = getNutrientValue(nutrients, [1003]);
    final carbs = getNutrientValue(nutrients, [1005]);
    final fat = getNutrientValue(nutrients, [1004]);
    final fiber = getNutrientValue(nutrients, [1079]);
    final sugar = getNutrientValue(nutrients, [2000]);

    return USDAFoodResult(
      fdcId: json['fdcId']?.toString() ?? '',
      description: json['description'] ?? json['lowercaseDescription'] ?? '',
      brandOwner: json['brandOwner'],
      calories: calories,
      macros: Macronutrients(
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber,
        sugar: sugar,
      ),
    );
  }
}

/// Serviço para buscar dados nutricionais da API USDA FoodData Central
class USDAService {
  // API Key gratuita - obtenha em: https://fdc.nal.usda.gov/api-key-signup.html
  // Por segurança, em produção use variáveis de ambiente
  static const String _apiKey =
      'lua753nIouKqYip8J8EDfxKM03vGOhQF9eDAqPts'; // Substitua pela sua API key
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  /// Busca alimentos pelo nome
  Future<List<USDAFoodResult>> searchFoods(String query) async {
    if (query.isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl/foods/search').replace(
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'pageSize': '15',
          'dataType': 'Foundation,SR Legacy,Branded',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List<dynamic>? ?? [];

        return foods.map((f) => USDAFoodResult.fromJson(f)).toList();
      } else if (response.statusCode == 429) {
        throw Exception(
          'Limite de requisições excedido. Tente novamente mais tarde.',
        );
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  /// Busca detalhes de um alimento específico pelo ID
  Future<USDAFoodResult?> getFoodDetails(String fdcId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/food/$fdcId',
      ).replace(queryParameters: {'api_key': _apiKey});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return USDAFoodResult.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar detalhes: $e');
    }
  }
}
