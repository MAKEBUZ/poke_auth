import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiHistoryService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucket = 'historial-ia';
  static const String _fileName = 'chat.txt';

  /// Anexa una entrada de chat (usuario y respuesta de IA) al archivo del usuario
  Future<void> appendEntry({
    required String userText,
    required String assistantText,
    DateTime? timestamp,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final path = '$userId/$_fileName';
    final now = timestamp ?? DateTime.now();
    final header = '--- ${now.toIso8601String()} ---\n';
    final block = StringBuffer()
      ..write(header)
      ..writeln('USER: ${userText.replaceAll('\n', ' ')}')
      ..writeln('POKE-IA: ${assistantText.replaceAll('\n', ' ')}')
      ..writeln();

    String existing = '';
    try {
      final bytes = await _supabase.storage.from(_bucket).download(path);
      if (bytes != null && bytes.isNotEmpty) {
        existing = utf8.decode(bytes);
      }
    } catch (_) {
      // Si no existe el archivo o bucket, se intentará crear al subir
    }

    final updated = existing + block.toString();
    final uploadBytes = utf8.encode(updated);

    await _supabase.storage.from(_bucket).uploadBinary(
      path,
      uploadBytes,
      fileOptions: const FileOptions(
        contentType: 'text/plain',
        upsert: true,
      ),
    );
  }

  /// Descarga el historial acumulado (chat.txt) del usuario como texto
  Future<String> getHistoryText() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    final path = '$userId/$_fileName';
    try {
      final bytes = await _supabase.storage.from(_bucket).download(path);
      if (bytes != null && bytes.isNotEmpty) {
        return utf8.decode(bytes);
      }
    } catch (_) {}
    return '';
  }

  /// Guarda una conversación completa como archivo independiente bajo conversaciones/
  /// Devuelve el nombre de archivo guardado (por ejemplo: 20241016_203015.txt)
  Future<String> saveConversationText(String conversationText, {String? title}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final folder = '$userId/conversaciones';
    final now = DateTime.now().toUtc();
    final ts = _formatTimestamp(now);
    final safeTitle = title == null || title.trim().isEmpty
        ? ''
        : '_${_slugify(title)}';
    final fileName = '$ts$safeTitle.txt';
    final path = '$folder/$fileName';

    final bytes = utf8.encode(conversationText);
    await _supabase.storage.from(_bucket).uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'text/plain',
        upsert: true,
      ),
    );
    return fileName;
  }

  /// Lista los archivos de conversaciones guardadas del usuario (solo nombres)
  Future<List<String>> listConversationFiles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    final folder = '$userId/conversaciones';
    final items = await _supabase.storage.from(_bucket).list(path: folder);
    final names = items
        .map((it) {
          try {
            // it.name está disponible en los objetos devueltos por Storage
            return (it as dynamic).name as String;
          } catch (_) {
            return null;
          }
        })
        .whereType<String>()
        .where((n) => n.endsWith('.txt'))
        .toList();
    names.sort((a, b) => b.compareTo(a)); // más recientes primero por nombre
    return names;
  }

  /// Descarga el contenido de una conversación guardada por nombre de archivo
  Future<String> downloadConversationText(String fileName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    final path = '$userId/conversaciones/$fileName';
    final bytes = await _supabase.storage.from(_bucket).download(path);
    if (bytes != null && bytes.isNotEmpty) {
      return utf8.decode(bytes);
    }
    return '';
  }

  String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y$m$d' '_' '$h$min$s';
  }

  String _slugify(String input) {
    final lower = input.toLowerCase();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final trimmed = replaced.replaceAll(RegExp(r'^-+|-+$'), '');
    return trimmed;
  }
}