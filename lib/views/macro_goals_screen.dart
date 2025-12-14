import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/food_controller.dart';
import '../../models/macro_goals.dart';

class MacroGoalsScreen extends StatefulWidget {
  const MacroGoalsScreen({super.key});

  @override
  State<MacroGoalsScreen> createState() => _MacroGoalsScreenState();
}

class _MacroGoalsScreenState extends State<MacroGoalsScreen> {
  late TextEditingController _caloriesController;
  late double _proteinPercent;
  late double _carbsPercent;
  late double _fatPercent;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<FoodController>(context, listen: false);
    final goals = controller.goals;

    _caloriesController = TextEditingController(
      text: goals.dailyCalories.toString(),
    );
    _proteinPercent = goals.proteinPercentage;
    _carbsPercent = goals.carbsPercentage;
    _fatPercent = goals.fatPercentage;
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  bool get _isValidPercentage {
    final total = _proteinPercent + _carbsPercent + _fatPercent;
    return (total - 100).abs() < 0.01;
  }

  MacroGoals get _currentGoals {
    return MacroGoals(
      dailyCalories: int.tryParse(_caloriesController.text) ?? 2000,
      proteinPercentage: _proteinPercent,
      carbsPercentage: _carbsPercent,
      fatPercentage: _fatPercent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas de Macronutrientes')),
      body: Consumer<FoodController>(
        builder: (context, controller, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de informações
                Card(
                  color: Colors.blue.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Configure suas metas diárias',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A soma das porcentagens deve ser 100%',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Campo de calorias
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Meta de Calorias Diárias',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_fire_department),
                    suffixText: 'kcal',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                // Proteína
                _buildMacroSlider(
                  label: 'Proteína',
                  value: _proteinPercent,
                  color: Colors.red,
                  icon: Icons.fitness_center,
                  onChanged: (value) {
                    setState(() {
                      _proteinPercent = value;
                    });
                  },
                ),

                // Carboidratos
                _buildMacroSlider(
                  label: 'Carboidratos',
                  value: _carbsPercent,
                  color: Colors.orange,
                  icon: Icons.grain,
                  onChanged: (value) {
                    setState(() {
                      _carbsPercent = value;
                    });
                  },
                ),

                // Gordura
                _buildMacroSlider(
                  label: 'Gordura',
                  value: _fatPercent,
                  color: Colors.yellow[700]!,
                  icon: Icons.opacity,
                  onChanged: (value) {
                    setState(() {
                      _fatPercent = value;
                    });
                  },
                ),

                // Indicador de total
                Card(
                  color: _isValidPercentage
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(_proteinPercent + _carbsPercent + _fatPercent).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isValidPercentage
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Preview das metas em gramas
                if (_isValidPercentage) ...[
                  const Text(
                    'Suas metas em gramas:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildGramsPreview(_currentGoals),
                  const SizedBox(height: 24),
                ],

                // Botão de salvar
                ElevatedButton.icon(
                  onPressed: _isValidPercentage && !controller.isLoading
                      ? () => _saveGoals(controller)
                      : null,
                  icon: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Salvar Metas'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),

                // Botão de resetar
                OutlinedButton.icon(
                  onPressed: () {
                    final defaults = MacroGoals.defaultGoals();
                    setState(() {
                      _caloriesController.text = defaults.dailyCalories
                          .toString();
                      _proteinPercent = defaults.proteinPercentage;
                      _carbsPercent = defaults.carbsPercentage;
                      _fatPercent = defaults.fatPercentage;
                    });
                  },
                  icon: const Icon(Icons.restore),
                  label: const Text('Restaurar Padrões'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMacroSlider({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    final gramsPerDay = _calculateGrams(value);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${value.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: color,
              onChanged: onChanged,
            ),
            Text(
              '≈ ${gramsPerDay.toStringAsFixed(0)}g por dia',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateGrams(double percentage) {
    final calories = int.tryParse(_caloriesController.text) ?? 2000;
    final macroCalories = calories * percentage / 100;
    // Proteína e carbs = 4 kcal/g, gordura = 9 kcal/g
    // Usar média de 4 para simplificar na visualização
    return macroCalories / 4;
  }

  Widget _buildGramsPreview(MacroGoals goals) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGramItem('Proteína', goals.proteinGrams, Colors.red),
        _buildGramItem('Carbs', goals.carbsGrams, Colors.orange),
        _buildGramItem('Gordura', goals.fatGrams, Colors.yellow[700]!),
      ],
    );
  }

  Widget _buildGramItem(String label, double grams, Color color) {
    return Column(
      children: [
        Text(
          '${grams.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Future<void> _saveGoals(FoodController controller) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = await controller.saveGoals(_currentGoals);

    if (error == null) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Metas salvas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }
}
