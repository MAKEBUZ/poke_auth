import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pokemon_controller.dart';
import '../controllers/team_controller.dart';

class PokemonDetailView extends StatelessWidget {
  final PokemonController controller = Get.find<PokemonController>();
  final TeamController teamController = Get.find<TeamController>();

  PokemonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pokemon = controller.pokemon.value;
      if (pokemon == null) {
        return const Scaffold(
          body: Center(
            child: Text(
              'No hay datos disponibles',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            // AppBar con imagen de fondo
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Color(controller.getBackgroundColor()),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  pokemon.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(controller.getBackgroundColor()),
                        Color(controller.getBackgroundColor()).withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'pokemon-${pokemon.id}',
                      child: Image.network(
                        pokemon.imageUrl,
                        height: 200,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 150,
                            color: Colors.white70,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                // Botón de favorito
                FutureBuilder<bool>(
                  future: teamController.isInTeam(pokemon.id),
                  builder: (context, snapshot) {
                    final isInTeam = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isInTeam ? Icons.favorite : Icons.favorite_border,
                        color: isInTeam ? Colors.red : Colors.white,
                        size: 28,
                      ),
                      onPressed: () async {
                         if (isInTeam) {
                           await teamController.removeFromTeam(pokemon.id);
                         } else {
                           await teamController.addToTeam(pokemon);
                         }
                       },
                    );
                  },
                ),
              ],
            ),

            // Contenido principal
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID y información básica
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(controller.getBackgroundColor()).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(controller.getBackgroundColor()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tipos
                      _buildSectionTitle('Tipos'),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: pokemon.types
                            .map((type) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Color(controller.typeColors[type] ?? 0xFF78C850),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    type,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 30),

                      // Estadísticas
                      if (pokemon.stats.isNotEmpty) ...[
                        _buildSectionTitle('Estadísticas'),
                        const SizedBox(height: 15),
                        ...pokemon.stats.entries.map((stat) => _buildStatBar(stat.key, stat.value)),
                        const SizedBox(height: 30),
                      ],

                      // Ataques
                      if (pokemon.attacks.isNotEmpty) ...[
                        _buildSectionTitle('Ataques'),
                        const SizedBox(height: 15),
                        ...pokemon.attacks.map((attack) => _buildAttackCard(attack)),
                        const SizedBox(height: 30),
                      ],

                      // Debilidades
                      if (pokemon.weaknesses.isNotEmpty) ...[
                        _buildSectionTitle('Debilidades'),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: pokemon.weaknesses
                              .map((weakness) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Color(controller.typeColors[weakness] ?? 0xFF78C850),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          weakness,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 30),
                      ],

                      // Espacio adicional al final
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatBar(String statName, int value) {
    final percentage = (value / 100).clamp(0.0, 1.0);
    Color barColor;
    
    if (percentage >= 0.8) {
      barColor = Colors.green;
    } else if (percentage >= 0.6) {
      barColor = Colors.orange;
    } else if (percentage >= 0.4) {
      barColor = Colors.yellow[700]!;
    } else {
      barColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttackCard(String attack) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(controller.getBackgroundColor()).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.flash_on,
              color: Color(controller.getBackgroundColor()),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              attack,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}