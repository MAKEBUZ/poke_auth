import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_view.dart';
import 'team_view.dart';
import 'poke_ia_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  _MainNavigationViewState createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    HomeView(),
    TeamView(),
    PokeIAView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red.shade400,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon),
            label: 'Pokédex',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Mi Equipo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'POKE-IA',
          ),
        ],
      ),
    );
  }
}