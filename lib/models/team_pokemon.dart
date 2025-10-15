import 'pokemon_model.dart';

class TeamPokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<String> weaknesses;
  List<String> attacks;
  final Map<String, int> stats;

  TeamPokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.weaknesses,
    required this.attacks,
    required this.stats,
  });

  // Convertir desde Pokemon regular
  factory TeamPokemon.fromPokemon(Pokemon pokemon) {
    return TeamPokemon(
      id: pokemon.id,
      name: pokemon.name,
      imageUrl: pokemon.imageUrl,
      types: pokemon.types,
      weaknesses: pokemon.weaknesses,
      attacks: List<String>.from(pokemon.attacks),
      stats: Map<String, int>.from(pokemon.stats),
    );
  }

  // Convertir desde datos de Supabase
  factory TeamPokemon.fromSupabaseJson(Map<String, dynamic> json) {
    return TeamPokemon(
      id: json['pokemon_id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      types: List<String>.from(json['types'] as List),
      weaknesses: List<String>.from(json['weaknesses'] as List),
      attacks: List<String>.from(json['attacks'] as List),
      stats: Map<String, int>.from(json['stats'] as Map),
    );
  }

  // Convertir a Pokemon regular
  Pokemon toPokemon() {
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