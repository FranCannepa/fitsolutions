import 'package:flutter/material.dart';

class MembershipCard extends StatelessWidget {
  final Map<String, dynamic> membership;

  const MembershipCard({super.key, required this.membership});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(membership['nombreMembresia']),
        subtitle: Row(
          children: [
            Text(membership['descripcion'] ?? 'No description'),
            const Spacer(),
            Text(membership['costo'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
