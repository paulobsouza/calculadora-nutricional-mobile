import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/food_controller.dart';
import '../controllers/auth_controller.dart';
import 'widgets/add_food_screen.dart';
import 'macro_goals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializa o listener do controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodController>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FoodController>(context);
    final authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculadora Nutricional"),
        actions: [
          // Botão de metas
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Metas de Macros',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MacroGoalsScreen()),
              );
            },
          ),
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              authController.logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Card de resumo de calorias
          _buildCaloriesSummary(controller),

          // Card de resumo de macros
          _buildMacrosSummary(controller),

          // Lista de Itens
          Expanded(
            child: controller.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Nenhum alimento registrado.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Toque + para adicionar",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.items.length,
                    itemBuilder: (context, index) {
                      final item = controller.items[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmar exclusão"),
                                content: Text(
                                  "Deseja realmente deletar ${item.name}?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      "Deletar",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );
                          String? error = await controller.deleteEntry(item.id);
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(error!),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.restaurant,
                              color: Colors.blue,
                            ),
                            title: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.portionGrams.toStringAsFixed(0)}g • ${item.date.toString().substring(0, 10)}',
                                ),
                                Text(
                                  item.macrosFormatted,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              "${item.calories} kcal",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFoodScreen()),
          );
        },
      ),
    );
  }

  Widget _buildCaloriesSummary(FoodController controller) {
    final goals = controller.goals;
    final consumed = controller.totalCalories;
    final remaining = goals.dailyCalories - consumed;
    final progress = consumed / goals.dailyCalories;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blueAccent.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Consumido",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "$consumed kcal",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Restante",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "$remaining kcal",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: remaining >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(
              progress > 1 ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Meta: ${goals.dailyCalories} kcal',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosSummary(FoodController controller) {
    final goals = controller.goals;
    final macros = controller.totalMacros;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMacroIndicator(
            'Proteína',
            macros.protein,
            goals.proteinGrams,
            Colors.red,
          ),
          _buildMacroIndicator(
            'Carbs',
            macros.carbs,
            goals.carbsGrams,
            Colors.orange,
          ),
          _buildMacroIndicator(
            'Gordura',
            macros.fat,
            goals.fatGrams,
            Colors.yellow[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroIndicator(
    String label,
    double consumed,
    double goal,
    Color color,
  ) {
    final progress = goal > 0 ? consumed / goal : 0.0;

    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeWidth: 4,
                ),
              ),
              Text(
                '${consumed.toStringAsFixed(0)}g',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '/ ${goal.toStringAsFixed(0)}g',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
