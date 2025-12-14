import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/macronutrients.dart';
import '../models/macro_goals.dart';
import '../services/database.dart';
import '../services/usda_service.dart';

class FoodController extends ChangeNotifier {
  final DatabaseService _service = DatabaseService();
  final USDAService _usdaService = USDAService();

  // Lista local para a View consumir
  List<FoodItem> _items = [];
  List<FoodItem> get items => _items;

  // Estado de carregamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Resultados da busca USDA
  List<USDAFoodResult> _searchResults = [];
  List<USDAFoodResult> get searchResults => _searchResults;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // Metas de macros do usuário
  MacroGoals _goals = MacroGoals.defaultGoals();
  MacroGoals get goals => _goals;

  // Calcular total de calorias
  int get totalCalories => _items.fold(0, (sum, item) => sum + item.calories);

  // Calcular total de macros do dia
  Macronutrients get totalMacros {
    return _items.fold(Macronutrients.zero(), (sum, item) => sum + item.macros);
  }

  // Atualiza o ID do usuário
  void updateUserId(String? userId) {
    _service.setUserId(userId);
    if (userId != null) {
      init();
      loadGoals();
    } else {
      _items = [];
      _goals = MacroGoals.defaultGoals();
      notifyListeners();
    }
  }

  void init() {
    _service.getFoodEntries().listen((snapshot) {
      _items =
          snapshot?.docs.map((doc) {
            return FoodItem.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList() ??
          [];
      notifyListeners();
    });
  }

  Future<void> loadGoals() async {
    try {
      final goalsMap = await _service.getMacroGoals();
      if (goalsMap != null) {
        _goals = MacroGoals.fromMap(goalsMap);
        notifyListeners();
      }
    } catch (e) {
      _goals = MacroGoals.defaultGoals();
    }
  }

  Future<String?> saveGoals(MacroGoals newGoals) async {
    if (!newGoals.isValid) {
      return "As porcentagens devem somar 100%";
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _service.saveMacroGoals(newGoals.toMap());
      _goals = newGoals;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Erro ao salvar metas: $e";
    }
  }

  Future<String?> searchUSDA(String query) async {
    if (query.length < 2) {
      _searchResults = [];
      notifyListeners();
      return null;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _usdaService.searchFoods(query);
      _isSearching = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSearching = false;
      notifyListeners();
      return "Erro na busca: $e";
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<String?> addFromUSDA(USDAFoodResult food, double portionGrams) async {
    if (portionGrams <= 0) return "Quantidade inválida.";

    _isLoading = true;
    notifyListeners();

    final portionMacros = food.macros.applyPortion(portionGrams);
    final portionCalories = ((food.calories * portionGrams) / 100).round();

    try {
      await _service.addFoodEntry({
        'name': food.description,
        'calories': portionCalories,
        'date': DateTime.now(),
        'portionGrams': portionGrams,
        'macros': portionMacros.toMap(),
        'fdcId': food.fdcId,
      });
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Erro ao salvar: $e";
    }
  }

  Future<String?> addEntry(String name, String caloriesStr) async {
    if (name.isEmpty || caloriesStr.isEmpty) return "Preencha todos os campos.";

    int? calories = int.tryParse(caloriesStr);
    if (calories == null || calories <= 0) return "Calorias inválidas.";

    _isLoading = true;
    notifyListeners();

    try {
      await _service.addFoodEntry({
        'name': name,
        'calories': calories,
        'date': DateTime.now(),
        'portionGrams': 100,
        'macros': Macronutrients.zero().toMap(),
      });
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Erro ao salvar: $e";
    }
  }

  Future<String?> deleteEntry(String documentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteFoodEntry(documentId);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Erro ao deletar: $e";
    }
  }
}
