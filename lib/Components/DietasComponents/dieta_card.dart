import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:flutter/material.dart';

class DietaCard extends StatelessWidget {
  final Dieta dieta;
  const DietaCard({super.key, required this.dieta});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dieta.nombre,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text("Calorias Totales: "),
                Text(dieta.caloriasTotales.toString()),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                const Text("Max Carbohidratos: "),
                Text(dieta.maxCarbohidratos.toString()),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                const Text("Frecuencia: "),
                Text(dieta.frecuenciaAlimentacion),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
