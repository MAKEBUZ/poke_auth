import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/team_pokemon.dart';

class TeamPokemonDetailView extends StatefulWidget {
  final TeamPokemon pokemon;

  const TeamPokemonDetailView({super.key, required this.pokemon});

  @override
  State<TeamPokemonDetailView> createState() => _TeamPokemonDetailViewState();
}

class _TeamPokemonDetailViewState extends State<TeamPokemonDetailView> {
  final TeamController teamController = Get.find<TeamController>();
  final TextEditingController attackController = TextEditingController();

  // Colores de tipos de Pokémon
  final Map<String, int> typeColors = {
    'Normal': 0xFFA8A878,
    'Fire': 0xFFF08030,
    'Water': 0xFF6890F0,
    'Electric': 0xFFF8D030,
    'Grass': 0xFF78C850,
    'Ice': 0xFF98D8D8,
    'Fighting': 0xFFC03028,
    'Poison': 0xFFA040A0,
    'Ground': 0xFFE0C068,
    'Flying': 0xFFA890F0,
    'Psychic': 0xFFF85888,
    'Bug': 0xFFA8B820,
    'Rock': 0xFFB8A038,
    'Ghost': 0xFF705898,
    'Dragon': 0xFF7038F8,
    'Dark': 0xFF705848,
    'Steel': 0xFFB8B8D0,
    'Fairy': 0xFFEE99AC,
  };

  @override
  void dispose() {
    attackController.dispose();
    super.dispose();
  }

  Color getBackgroundColor() {
    if (widget.pokemon.types.isNotEmpty) {
      return Color(typeColors[widget.pokemon.types.first] ?? 0xFF78C850);
    }
    return const Color(0xFF78C850);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: getBackgroundColor(),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.pokemon.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                      getBackgroundColor(),
                      getBackgroundColor().withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'pokemon-${widget.pokemon.id}',
                    child: Image.network(
                      widget.pokemon.imageUrl,
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
                          color: getBackgroundColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          '#${widget.pokemon.id.toString().padLeft(3, '0')}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: getBackgroundColor(),
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
                      children: widget.pokemon.types
                          .map((type) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(typeColors[type] ?? 0xFF78C850),
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30),

                    // Debilidades
                    _buildSectionTitle('Debilidades'),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: widget.pokemon.weaknesses
                          .map((weakness) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(typeColors[weakness] ?? 0xFF78C850),
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30),

                    // Ataques
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Ataques'),
                        IconButton(
                          onPressed: () => _showEditAttackDialog(),
                          icon: Icon(
                            Icons.edit,
                            color: getBackgroundColor(),
                          ),
                          tooltip: 'Editar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        widget.pokemon.attacks.isNotEmpty 
                            ? widget.pokemon.attacks.join(', ') 
                            : 'Sin ataques configurados',
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.pokemon.attacks.isNotEmpty 
                              ? Colors.black87 
                              : Colors.grey.shade500,
                          fontStyle: widget.pokemon.attacks.isNotEmpty 
                              ? FontStyle.normal 
                              : FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botón de cerrar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: getBackgroundColor(),
      ),
    );
  }

  void _showEditAttackDialog() {
    attackController.text = widget.pokemon.attacks.isNotEmpty ? widget.pokemon.attacks.first : '';
    
    Get.dialog(
      AlertDialog(
        title: Text('Editar Ataque de ${widget.pokemon.name}'),
        content: TextField(
          controller: attackController,
          decoration: const InputDecoration(
            labelText: 'Ataque',
            hintText: 'Ingresa el nombre del ataque',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateAttack();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: getBackgroundColor(),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _updateAttack() {
    final newAttack = attackController.text.trim();
    teamController.updatePokemonAttacks(widget.pokemon.id, [newAttack]);
    setState(() {
      widget.pokemon.attacks = [newAttack];
    });
  }
}