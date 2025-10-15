import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'pokemon_attacks';

  // Guardar ataques modificados de un Pokemon
  Future<void> saveCustomAttacks(int pokemonId, List<String> attacks) async {
    try {
      final attacksJson = attacks.join('|'); // Usar | como separador
      
      await _supabase
          .from(_tableName)
          .upsert({
            'pokemon_id': pokemonId,
            'attacks': attacksJson,
          });
    } catch (e) {
      throw Exception('Error al guardar ataques personalizados: $e');
    }
  }

  // Obtener ataques modificados de un Pokemon
  Future<List<String>?> getCustomAttacks(int pokemonId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('attacks')
          .eq('pokemon_id', pokemonId)
          .maybeSingle();

      if (response != null && response['attacks'] != null) {
        final attacksString = response['attacks'] as String;
        return attacksString.split('|');
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener ataques personalizados: $e');
    }
  }

  // Eliminar ataques modificados de un Pokemon
  Future<void> deleteCustomAttacks(int pokemonId) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('pokemon_id', pokemonId);
    } catch (e) {
      throw Exception('Error al eliminar ataques personalizados: $e');
    }
  }

  // Verificar si un Pokemon tiene ataques modificados
  Future<bool> hasCustomAttacks(int pokemonId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('pokemon_id')
          .eq('pokemon_id', pokemonId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Error al verificar ataques personalizados: $e');
    }
  }
}