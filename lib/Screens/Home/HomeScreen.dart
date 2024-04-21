import 'package:fitsolutions/Components/HomeComponents/HomeRouteButton.dart';
import 'package:fitsolutions/Screens/Calendar/calendarioScreen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final buttonData = [
      {"texto": "Calendario", "route": "/calendario"},
      {"texto": "Perfil", "route": "/perfil"},
      {"texto": "Actividades", "route": "/actividades"},
      {"texto": "Mis Dietas", "route": "/dietas"},
      {"texto": "Mis Ejercicios", "route": "/ejercicios"},
    ];

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final item in buttonData)
              //validar que opciones mostrar en base al tipo de usuario (basico, propietario, particular)
              HomeRouteButton(
                key: ValueKey(item['texto']),
                texto: item['texto'],
                route: item['route'] ?? '',
              ),
          ],
        ),
      ),
    );
  }
}
