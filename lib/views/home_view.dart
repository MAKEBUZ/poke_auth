import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pokemon_controller.dart';
import '../controllers/team_controller.dart';
import 'pokemon_detail_view.dart';
import 'team_view.dart';

class HomeView extends StatelessWidget {
  final PokemonController controller = Get.put(PokemonController());
  final TeamController teamController = Get.put(TeamController());
  final TextEditingController searchController = TextEditingController();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o número',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    controller.clearSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  controller.searchPokemon(value);
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Mostrar resultados o mensajes
            Expanded(
              child: Obx(() {
                // Mostrar indicador de carga
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // Mostrar mensaje de error
                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          controller.error.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }
                
                // Mostrar resultado de la búsqueda
                if (controller.pokemon.value != null) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => PokemonDetailView());
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(controller.getBackgroundColor()).withOpacity(0.7),
                              Color(controller.getBackgroundColor()),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ID y nombre
                                Text(
                                  '#${controller.pokemon.value!.id} - ${controller.pokemon.value!.name}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Imagen
                                Hero(
                                  tag: 'pokemon-${controller.pokemon.value!.id}',
                                  child: Image.network(
                                    controller.pokemon.value!.imageUrl,
                                    height: 200,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 100);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Tipos
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: controller.pokemon.value!.types
                                      .map((type) => Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                            child: Chip(
                                              label: Text(
                                                type,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              backgroundColor: Color(controller.typeColors[type] ?? 0xFF78C850),
                                            ),
                                          ))
                                      .toList(),
                                ),

                                // Ataques
                                if (controller.pokemon.value!.attacks.isNotEmpty) ...[
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Ataques:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: controller.pokemon.value!.attacks
                                        .take(4)
                                        .map((attack) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                attack,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],

                                // Estadísticas principales
                                if (controller.pokemon.value!.stats.isNotEmpty) ...[
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Estadísticas:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatChip('HP', controller.pokemon.value!.stats['hp'] ?? 0),
                                      _buildStatChip('ATK', controller.pokemon.value!.stats['attack'] ?? 0),
                                      _buildStatChip('DEF', controller.pokemon.value!.stats['defense'] ?? 0),
                                      _buildStatChip('SPD', controller.pokemon.value!.stats['speed'] ?? 0),
                                    ],
                                  ),
                                ],
                                
                                const SizedBox(height: 15),
                                const Text(
                                  'Toca para ver más detalles',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            
                            // Botón favorito en la esquina superior derecha
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Obx(() => FutureBuilder<bool>(
                                future: teamController.isInTeam(controller.pokemon.value!.id),
                                builder: (context, snapshot) {
                                  final isInTeam = snapshot.data ?? false;
                                  return FloatingActionButton.small(
                                    onPressed: () async {
                                      if (await teamController.isInTeam(controller.pokemon.value!.id)) {
                                        await teamController.removeFromTeam(controller.pokemon.value!.id);
                                        // Forzar actualización del estado
                                        teamController.update();
                                      } else {
                                        await teamController.addToTeam(controller.pokemon.value!);
                                        // Forzar actualización del estado
                                        teamController.update();
                                      }
                                    },
                                    backgroundColor: isInTeam 
                                        ? Colors.red.shade600 
                                        : Colors.white,
                                    child: Icon(
                                      isInTeam 
                                          ? Icons.favorite 
                                          : Icons.favorite_border,
                                      color: isInTeam 
                                          ? Colors.white 
                                          : Colors.red.shade600,
                                    ),
                                  );
                                },
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                
                // Estado inicial
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.catching_pokemon, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Busca un Pokémon por nombre o número',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}