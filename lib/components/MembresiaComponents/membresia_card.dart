import 'package:flutter/material.dart';

class MembershipCard extends StatelessWidget {
  final Map<String, dynamic> membership;

  const MembershipCard({super.key, required this.membership});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              membership['nombreMembresia'],
              style:
                  const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Text(
              membership['descripcion'] ?? 'No hay descripcion',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Costo:"),
                Text(
                  " \$ ${membership['costo']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
