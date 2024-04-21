import 'package:fitsolutions/Models/Actividad.dart'; // Assuming Actividad.dart defines Actividad class
import 'package:flutter/material.dart';

class CartaActividad extends StatelessWidget {
  final Actividad activity;

  const CartaActividad({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.nombre,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16),
                Text(' ${activity.duracion.inMinutes} minutes'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                Text(' ${activity.cupos} slots'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Usage: Create a list of CartaActividad objects

final List<CartaActividad> actividades = [
  CartaActividad(
    activity: Actividad(
      nombre: "Yoga matutino",
      duracion: const Duration(minutes: 60),
      cupos: 10,
    ),
  ),
  // ... other CartaActividad objects using Actividad data
];
