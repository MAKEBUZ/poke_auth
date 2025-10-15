import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokemonService {
  final String baseUrl = 'https://pokeapi.co/api/v2';
  
  // Mapa de tipos y sus debilidades
  final Map<String, List<String>> typeWeaknesses = {
    'Normal': ['Fighting'],
    'Fire': ['Water', 'Ground', 'Rock'],
    'Water': ['Electric', 'Grass'],
    'Electric': ['Ground'],
    'Grass': ['Fire', 'Ice', 'Poison', 'Flying', 'Bug'],
    'Ice': ['Fire', 'Fighting', 'Rock', 'Steel'],
    'Fighting': ['Flying', 'Psychic', 'Fairy'],
    'Poison': ['Ground', 'Psychic'],
    'Ground': ['Water', 'Grass', 'Ice'],
    'Flying': ['Electric', 'Ice', 'Rock'],
    'Psychic': ['Bug', 'Ghost', 'Dark'],
    'Bug': ['Fire', 'Flying', 'Rock'],
    'Rock': ['Water', 'Grass', 'Fighting', 'Ground', 'Steel'],
    'Ghost': ['Ghost', 'Dark'],
    'Dragon': ['Ice', 'Dragon', 'Fairy'],
    'Dark': ['Fighting', 'Bug', 'Fairy'],
    'Steel': ['Fire', 'Fighting', 'Ground'],
    'Fairy': ['Poison', 'Steel']
  };

  // Obtener un Pokémon por su nombre o número
  Future<Pokemon> getPokemon(String nameOrId) async {
    try {
      // Convertir a minúsculas para asegurar compatibilidad con la API
      final String query = nameOrId.toLowerCase();
      
      // Realizar la petición a la API
      final response = await http.get(Uri.parse('$baseUrl/pokemon/$query'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Crear el objeto Pokemon
        Pokemon pokemon = Pokemon.fromJson(data);
        
        // Calcular debilidades basadas en los tipos
        pokemon = _calculateWeaknesses(pokemon);
        
        return pokemon;
      } else {
        throw Exception('No se pudo cargar el Pokémon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al buscar el Pokémon: $e');
    }
  }

  // Calcular las debilidades basadas en los tipos del Pokémon
  Pokemon _calculateWeaknesses(Pokemon pokemon) {
    Set<String> allWeaknesses = {};
    
    // Para cada tipo del Pokémon, agregar sus debilidades
    for (String type in pokemon.types) {
      final List<String>? weaknesses = typeWeaknesses[type];
      if (weaknesses != null) {
        allWeaknesses.addAll(weaknesses);
      }
    }
    
  // Crear un nuevo Pokémon con las debilidades calculadas
    return Pokemon(
      id: pokemon.id,
      name: pokemon.name,
      imageUrl: pokemon.imageUrl,
      types: pokemon.types,
      weaknesses: allWeaknesses.toList(),
      attacks: pokemon.attacks,
      stats: pokemon.stats,
    );
  }
}