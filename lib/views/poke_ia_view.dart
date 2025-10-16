import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../controllers/team_controller.dart';
import '../models/team_pokemon.dart';
import '../services/ai_history_service.dart';

class PokeIAView extends StatefulWidget {
  const PokeIAView({super.key});

  @override
  State<PokeIAView> createState() => _PokeIAViewState();
}

class _PokeIAViewState extends State<PokeIAView> {
  final TeamController teamController = Get.put(TeamController());

  final TextEditingController _inputController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _contextSent = false;

  GenerativeModel? _model;
  ChatSession? _chat;

  @override
  void initState() {
    super.initState();
    _setupModel();
    // Asegurar que el equipo esté cargado
    teamController.loadTeam();
  }

  void _setupModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      // Mostrar mensaje de error en UI si falta la API key
      setState(() {
        _messages.add(_ChatMessage(
          text:
              'Configura GEMINI_API_KEY en tu .env para usar POKE-IA. No se encontró la clave.',
          isUser: false,
        ));
      });
      return;
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    _chat = _model!.startChat();
  }

  String _buildTeamContext(List<TeamPokemon> team) {
    if (team.isEmpty) {
      return 'Mi equipo está vacío actualmente.';
    }
    final buffer = StringBuffer('Información del equipo (desde Supabase):\n');
    for (final p in team) {
      buffer.writeln('- ${p.name}');
      buffer.writeln('  Tipos: ${p.types.join(', ')}');
      if (p.weaknesses.isNotEmpty) {
        buffer.writeln('  Debilidades: ${p.weaknesses.join(', ')}');
      }
      if (p.attacks.isNotEmpty) {
        buffer.writeln('  Ataques: ${p.attacks.join(', ')}');
      }
      if (p.stats.isNotEmpty) {
        buffer.writeln('  Stats: ${p.stats.entries.map((e) => '${e.key}:${e.value}').join(', ')}');
      }
    }
    return buffer.toString();
  }

  String _baseInstruction(List<TeamPokemon> team) {
    final teamCtx = _buildTeamContext(team);
    return [
      'Eres POKE-IA, un asesor estratégico de batallas Pokémon. Responde SIEMPRE en español.',
      'Usa el siguiente contexto de mi equipo para tus recomendaciones:',
      teamCtx,
      'Reglas:',
      ' - Da respuestas prácticas y accionables (listas, bullets y pasos).',
      ' - Si faltan datos, indica supuestos razonables.',
      ' - Referencia tipos, ventajas y sinergias cuando aplique.',
      ' - Evita redundancias y sé conciso.',
    ].join('\n');
  }

  Future<void> _sendPrompt(String prompt) async {
    if (_chat == null) return;
    setState(() => _isLoading = true);

    try {
      // Enviar contexto la primera vez
      if (!_contextSent) {
        final base = _baseInstruction(teamController.team);
        await _chat!.sendMessage(Content.text(base));
        _contextSent = true;
      }

      // Agregar mensaje del usuario a la UI
      setState(() {
        _messages.add(_ChatMessage(text: prompt, isUser: true));
      });

      // Enviar mensaje del usuario al modelo
      final response = await _chat!.sendMessage(Content.text(prompt));
      final text = response.text ?? 'Sin respuesta';

      setState(() {
        _messages.add(_ChatMessage(text: text, isUser: false));
      });

      // Guardar historial en Supabase Storage (bucket: historial-ia)
      try {
        final history = AiHistoryService();
        await history.appendEntry(userText: prompt, assistantText: text);
      } catch (_) {
        // Ignorar errores de guardado para no interrumpir la experiencia de chat
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Error al consultar POKE-IA: $e',
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendPredefinedPrompt(String request) {
    final prompt = [
      request,
      'Ten en cuenta sinergias, cobertura de tipos, prioridades y posibles estrategias de rivales.',
    ].join('\n');
    _sendPrompt(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POKE-IA'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Guardar conversación',
            onPressed: _saveCurrentConversation,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver conversaciones',
            onPressed: _showConversationsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (e) {
                Get.snackbar('Error', 'No se pudo cerrar sesión', snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chips de consultas rápidas
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Fuertes contra mi equipo'),
                  onPressed: () => _sendPredefinedPrompt(
                      '¿Qué pokémon son FUERTES en contra de mi equipo? Enumera por tipo y explica por qué.'),
                ),
                ActionChip(
                  label: const Text('Débiles contra mi equipo'),
                  onPressed: () => _sendPredefinedPrompt(
                      '¿Qué pokémon son DÉBILES frente a mi equipo? Indica vulnerabilidades y contraataques.'),
                ),
                ActionChip(
                  label: const Text('Mejores ataques'),
                  onPressed: () => _sendPredefinedPrompt(
                      'Sugiere los MEJORES ATAQUES para mi equipo según tipos, cobertura y sinergias.'),
                ),
                ActionChip(
                  label: const Text('Jugadas y decisiones'),
                  onPressed: () => _sendPredefinedPrompt(
                      'Propón jugadas, acciones y decisiones en batalla: apertura, cambios, bait, presión y cierre.'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? Colors.red.shade300
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu consulta para POKE-IA...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.red.shade400,
                    onPressed: () {
                      final text = _inputController.text.trim();
                      if (text.isNotEmpty) {
                        _inputController.clear();
                        _sendPrompt(text);
                      }
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String _serializeConversation() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    buffer.writeln('=== Conversación POKE-IA (${now.toIso8601String()}) ===');
    for (final m in _messages) {
      buffer.writeln(m.isUser ? 'USER: ${m.text}' : 'POKE-IA: ${m.text}');
    }
    return buffer.toString();
  }

  Future<void> _saveCurrentConversation() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay mensajes para guardar.')),
      );
      return;
    }
    try {
      final text = _serializeConversation();
      final service = AiHistoryService();
      final fileName = await service.saveConversationText(text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversación guardada: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Future<void> _showConversationsDialog() async {
    final service = AiHistoryService();
    List<String> files = [];
    try {
      files = await service.listConversationFiles();
    } catch (e) {
      files = [];
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Conversaciones guardadas'),
          content: SizedBox(
            width: 400,
            child: files.isEmpty
                ? const Text('No hay conversaciones guardadas.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final name = files[index];
                      return ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(name),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _openConversation(name);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            )
          ],
        );
      },
    );
  }

  Future<void> _openConversation(String fileName) async {
    final service = AiHistoryService();
    String text = '';
    try {
      text = await service.downloadConversationText(fileName);
    } catch (e) {
      text = 'Error al descargar: $e';
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(fileName),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: SelectableText(text.isEmpty ? 'Sin contenido' : text),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            )
          ],
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}