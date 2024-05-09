import 'package:fitsolutions/Modelo/Actividad.dart'; // Assuming Actividad.dart defines Actividad class
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
                Text(' ${activity.duracion}'),
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
