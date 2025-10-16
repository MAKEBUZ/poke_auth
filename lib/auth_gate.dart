import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/auth_page.dart';
import 'views/main_navigation_view.dart';
import 'services/team_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final SupabaseClient _client = Supabase.instance.client;
  bool _teamEnsured = false;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios de autenticación
    _client.auth.onAuthStateChange.listen((state) async {
      final session = _client.auth.currentSession;
      if (session != null && !_teamEnsured) {
        _teamEnsured = true;
        try {
          final teamService = TeamService();
          await teamService.ensureInitialTeamForUser();
        } catch (_) {
          // Ignorar errores de asignación inicial
        }
        if (mounted) setState(() {});
      } else if (session == null) {
        _teamEnsured = false;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _client.auth.currentSession;
    if (session != null) {
      return MainNavigationView();
    }
    return const AuthPage();
  }
}