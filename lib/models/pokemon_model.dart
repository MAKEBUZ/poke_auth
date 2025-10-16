class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<String> weaknesses;
  final List<String> attacks;
  final Map<String, int> stats;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.weaknesses,
    this.attacks = const [],
    this.stats = const {},
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Extraer ID del Pokémon
    final int id = json['id'];
    
    // Extraer nombre y convertir primera letra a mayúscula
    final String name = json['name'].toString().capitalize();
    
    // Obtener URL de la imagen
    final String imageUrl = json['sprites']['other']['official-artwork']['front_default'] ?? 
                           json['sprites']['front_default'] ?? 
                           'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    
    // Extraer tipos
    final List<String> types = (json['types'] as List)
        .map((type) => type['type']['name'].toString().capitalize())
        .toList();
    
    // Extraer ataques (moves)
    final List<String> attacks = (json['moves'] as List?)
        ?.take(4) // Tomar solo los primeros 4 ataques
        ?.map((move) => move['move']['name'].toString().replaceAll('-', ' ').capitalize())
        ?.toList() ?? [];
    
    // Extraer estadísticas
    final Map<String, int> stats = {};
    if (json['stats'] != null) {
      for (var stat in json['stats']) {
        String statName = stat['stat']['name'].toString();
        int statValue = stat['base_stat'];
        stats[statName] = statValue;
      }
    }
    
    // Las debilidades no vienen directamente en la API, se calcularán en el servicio
    // Por ahora dejamos una lista vacía
    final List<String> weaknesses = [];
    
    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: types,
      weaknesses: weaknesses,
      attacks: attacks,
      stats: stats,
    );
  }
}

// Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}