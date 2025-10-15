import 'package:get/get.dart';
import '../models/pokemon_model.dart';
import '../models/team_pokemon.dart';
import '../services/team_service.dart';
import '../services/database_service.dart';

class TeamController extends GetxController {
  final TeamService _teamService = TeamService();
  final DatabaseService _databaseService = DatabaseService();
  
  // Variables observables
  final RxList<TeamPokemon> team = <TeamPokemon>[].obs;
  final Rx<TeamPokemon?> selectedPokemon = Rx<TeamPokemon?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTeam();
  }

  // Cargar equipo desde Supabase
  Future<void> loadTeam() async {
    isLoading.value = true;
    try {
      final teamData = await _teamService.getTeam();
      team.value = teamData;
    } catch (e) {
      print('Error loading team: $e');
      Get.snackbar(
        'Error',
        'No se pudo cargar el equipo',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Agregar Pokemon al equipo
  Future<void> addToTeam(Pokemon pokemon) async {
    try {
      await _teamService.addToTeam(pokemon);
      await loadTeam();
      Get.snackbar(
        'Éxito',
        '${pokemon.name} agregado al equipo',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo agregar ${pokemon.name} al equipo',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remover Pokemon del equipo
  Future<void> removeFromTeam(int pokemonId) async {
    try {
      final pokemon = await _teamService.getTeamPokemon(pokemonId);
      await _teamService.removeFromTeam(pokemonId);
      await _databaseService.deleteCustomAttacks(pokemonId);
      await loadTeam();
      
      if (selectedPokemon.value?.id == pokemonId) {
        selectedPokemon.value = null;
      }
      
      Get.snackbar(
        'Éxito',
        '${pokemon?.name ?? 'Pokemon'} removido del equipo',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo remover el Pokemon del equipo',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Verificar si un Pokémon está en el equipo
  Future<bool> isInTeam(int pokemonId) async {
    try {
      return await _teamService.isInTeam(pokemonId);
    } catch (e) {
      return false;
    }
  }

  // Seleccionar un Pokemon para ver detalles
  void selectPokemon(TeamPokemon pokemon) {
    selectedPokemon.value = pokemon;
  }

  // Actualizar ataques de un Pokemon
  Future<void> updatePokemonAttacks(int pokemonId, List<String> newAttacks) async {
    try {
      // Guardar en Supabase (tabla pokemon_attacks)
      await _databaseService.saveCustomAttacks(pokemonId, newAttacks);
      
      // Actualizar en Supabase (tabla team_pokemon)
      await _teamService.updatePokemonAttacks(pokemonId, newAttacks);
      
      // Recargar equipo
      await loadTeam();
      
      // Actualizar Pokemon seleccionado si es el mismo
      if (selectedPokemon.value?.id == pokemonId) {
        selectedPokemon.value = await _teamService.getTeamPokemon(pokemonId);
      }
      
      Get.snackbar(
        'Éxito',
        'Ataques actualizados correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron actualizar los ataques',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Obtener ataques (personalizados si existen, originales si no)
  Future<List<String>> getPokemonAttacks(int pokemonId) async {
    final customAttacks = await _databaseService.getCustomAttacks(pokemonId);
    if (customAttacks != null) {
      return customAttacks;
    }
    
    final teamPokemon = await _teamService.getTeamPokemon(pokemonId);
    return teamPokemon?.attacks ?? [];
  }

  // Recargar equipo
  Future<void> reloadTeam() async {
    await loadTeam();
  }

  // Obtener tamaño del equipo
  Future<int> get teamSize async => await _teamService.getTeamSize();

  // Limpiar todo el equipo
  Future<void> clearTeam() async {
    try {
      // Eliminar ataques personalizados de todos los Pokemon
      for (var pokemon in team) {
        await _databaseService.deleteCustomAttacks(pokemon.id);
      }
      
      await _teamService.clearTeam();
      team.clear();
      selectedPokemon.value = null;
      
      Get.snackbar(
        'Éxito',
        'Equipo limpiado completamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo limpiar el equipo',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}