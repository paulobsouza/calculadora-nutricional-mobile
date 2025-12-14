import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/food_controller.dart';
import '../../services/usda_service.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _portionController = TextEditingController(text: '100');
  final _manualNameController = TextEditingController();
  final _manualCaloriesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  USDAFoodResult? _selectedFood;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _portionController.dispose();
    _manualNameController.dispose();
    _manualCaloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Alimento'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Buscar'),
            Tab(icon: Icon(Icons.edit), text: 'Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSearchTab(), _buildManualTab()],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Consumer<FoodController>(
      builder: (context, controller, _) {
        return Column(
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar alimento',
                  hintText: 'Ex: rice, chicken, apple...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            controller.clearSearch();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.length >= 2) {
                    controller.searchUSDA(value);
                  }
                },
              ),
            ),

            // Indicador de carregamento
            if (controller.isSearching)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),

            // Lista de resultados
            Expanded(
              child: controller.searchResults.isEmpty
                  ? Center(
                      child: Text(
                        controller.isSearching
                            ? 'Buscando...'
                            : 'Digite para buscar alimentos\n(dados em inglês - USDA)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final food = controller.searchResults[index];
                        return _buildFoodResultTile(food, controller);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFoodResultTile(USDAFoodResult food, FoodController controller) {
    final isSelected = _selectedFood?.fdcId == food.fdcId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
      child: ExpansionTile(
        leading: Icon(
          Icons.restaurant,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
        title: Text(
          food.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${food.calories} kcal / 100g'),
            if (food.brandOwner != null)
              Text(
                food.brandOwner!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detalhes dos macros
                _buildMacroDetail('Proteína', food.macros.protein, 'g'),
                _buildMacroDetail('Carboidratos', food.macros.carbs, 'g'),
                _buildMacroDetail('Gordura', food.macros.fat, 'g'),
                _buildMacroDetail('Fibra', food.macros.fiber, 'g'),
                _buildMacroDetail('Açúcar', food.macros.sugar, 'g'),

                const Divider(),

                // Campo de porção
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _portionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade (g)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _addFood(food, controller),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            _selectedFood = expanded ? food : null;
          });
        },
      ),
    );
  }

  Widget _buildMacroDetail(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _addFood(USDAFoodResult food, FoodController controller) async {
    final portion = double.tryParse(_portionController.text);
    if (portion == null || portion <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma quantidade válida'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = await controller.addFromUSDA(food, portion);

    if (error == null) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${food.description} adicionado!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildManualTab() {
    return Consumer<FoodController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Adicionar alimento manualmente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use esta opção se não encontrar o alimento na busca.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _manualNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Alimento',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _manualCaloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calorias (kcal)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_fire_department),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo obrigatório';
                    if (int.tryParse(value!) == null) {
                      return 'Digite um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () => _addManualFood(controller),
                  icon: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: const Text('Adicionar Alimento'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addManualFood(FoodController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = await controller.addEntry(
      _manualNameController.text,
      _manualCaloriesController.text,
    );

    if (error == null) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Alimento adicionado!'),
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
