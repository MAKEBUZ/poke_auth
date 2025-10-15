import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pokemon_model.dart';
import '../models/team_pokemon.dart';

class TeamService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'team_pokemon';

  // Agregar Pokemon al equipo
  Future<void> addToTeam(Pokemon pokemon) async {
    try {
      final teamPokemon = TeamPokemon.fromPokemon(pokemon);
      
      await _supabase
          .from(_tableName)
          .upsert({
            'pokemon_id': pokemon.id,
            'name': teamPokemon.name,
            'image_url': teamPokemon.imageUrl,
            'types': teamPokemon.types,
            'weaknesses': teamPokemon.weaknesses,
            'attacks': teamPokemon.attacks,
            'stats': teamPokemon.stats,
          });
    } catch (e) {
      throw Exception('Error al agregar Pokemon al equipo: $e');
    }
  }

  // Remover Pokemon del equipo
  Future<void> removeFromTeam(int pokemonId) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('pokemon_id', pokemonId);
    } catch (e) {
      throw Exception('Error al remover Pokemon del equipo: $e');
    }
  }

  // Obtener todos los Pokemon del equipo
  Future<List<TeamPokemon>> getTeam() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select();

      return (response as List)
          .map((data) => TeamPokemon.fromSupabaseJson(data))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener el equipo: $e');
    }
  }

  // Verificar si un Pokemon está en el equipo
  Future<bool> isInTeam(int pokemonId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('pokemon_id')
          .eq('pokemon_id', pokemonId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar si Pokemon está en el equipo: $e');
    }
  }

  // Limpiar todo el equipo
  Future<void> clearTeam() async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .neq('pokemon_id', 0); // Eliminar todos los registros
    } catch (e) {
      throw Exception('Error al limpiar el equipo: $e');
    }
  }

  // Actualizar ataques de un Pokemon
  Future<void> updatePokemonAttacks(int pokemonId, List<String> newAttacks) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'attacks': newAttacks})
          .eq('pokemon_id', pokemonId);
    } catch (e) {
      throw Exception('Error al actualizar ataques del Pokemon: $e');
    }
  }

  // Obtener un Pokemon específico del equipo
  Future<TeamPokemon?> getTeamPokemon(int pokemonId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('pokemon_id', pokemonId)
          .maybeSingle();

      if (response != null) {
        return TeamPokemon.fromSupabaseJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener Pokemon del equipo: $e');
    }
  }

  // Obtener el número de Pokemon en el equipo
  Future<int> getTeamSize() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('pokemon_id');

      return (response as List).length;
    } catch (e) {
      throw Exception('Error al obtener el tamaño del equipo: $e');
    }
  }
}