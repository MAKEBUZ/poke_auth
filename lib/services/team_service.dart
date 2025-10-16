import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pokemon_model.dart';
import '../models/team_pokemon.dart';
import 'pokemon_service.dart';
import 'dart:math';

class TeamService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'team_pokemon';

  // Agregar Pokemon al equipo
  Future<void> addToTeam(Pokemon pokemon) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      final teamPokemon = TeamPokemon.fromPokemon(pokemon);
      
      await _supabase
          .from(_tableName)
          .upsert({
            'user_id': userId,
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
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      await _supabase
          .from(_tableName)
          .delete()
          .eq('pokemon_id', pokemonId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error al remover Pokemon del equipo: $e');
    }
  }

  // Obtener todos los Pokemon del equipo
  Future<List<TeamPokemon>> getTeam() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId);

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
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      final response = await _supabase
          .from(_tableName)
          .select('pokemon_id')
          .eq('pokemon_id', pokemonId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar si Pokemon está en el equipo: $e');
    }
  }

  // Limpiar todo el equipo
  Future<void> clearTeam() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      await _supabase
          .from(_tableName)
          .delete()
          .eq('user_id', userId); // Eliminar todos los registros del usuario
    } catch (e) {
      throw Exception('Error al limpiar el equipo: $e');
    }
  }

  // Actualizar ataques de un Pokemon
  Future<void> updatePokemonAttacks(int pokemonId, List<String> newAttacks) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      await _supabase
          .from(_tableName)
          .update({'attacks': newAttacks})
          .eq('pokemon_id', pokemonId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error al actualizar ataques del Pokemon: $e');
    }
  }

  // Obtener un Pokemon específico del equipo
  Future<TeamPokemon?> getTeamPokemon(int pokemonId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('pokemon_id', pokemonId)
          .eq('user_id', userId)
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
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      final response = await _supabase
          .from(_tableName)
          .select('pokemon_id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      throw Exception('Error al obtener el tamaño del equipo: $e');
    }
  }

  // Asignar equipo inicial al usuario si no tiene uno
  Future<void> ensureInitialTeamForUser({int teamSize = 6, int maxPokemonId = 151}) async {
    return;
  }

  // Generar y asignar equipo inicial
  Future<void> assignInitialTeamForUser({int teamSize = 6, int maxPokemonId = 151}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final pokemonService = PokemonService();
    final random = Random();
    final ids = <int>{};

    while (ids.length < teamSize) {
      ids.add(random.nextInt(maxPokemonId) + 1);
    }

    for (final id in ids) {
      try {
        final pokemon = await pokemonService.getPokemon(id.toString());
        await addToTeam(pokemon);
      } catch (_) {
        // Ignorar errores individuales y continuar
      }
    }
  }
}