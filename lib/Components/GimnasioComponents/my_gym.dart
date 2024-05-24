import 'package:flutter/material.dart';

class MyGym extends StatelessWidget {
  final Map<String, dynamic> myGym;

  const MyGym({super.key, required this.myGym});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              myGym['nombreGimnasio'] as String,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16.0),
                const SizedBox(width: 8.0),
                Text(myGym['direccion'] as String),
              ],
            ),
            if (myGym['telefono'] != null &&
                myGym['telefono'].toString().isNotEmpty)
              const SizedBox(height: 8.0),
            if (myGym['telefono'] != null &&
                myGym['telefono'].toString().isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.phone, size: 16.0),
                  const SizedBox(width: 8.0),
                  Text(myGym['telefono'] as String),
                ],
              ),
            if (myGym['horario'] != null &&
                myGym['horario'].toString().isNotEmpty)
              const SizedBox(height: 8.0),
            if (myGym['horario'] != null &&
                myGym['horario'].toString().isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16.0),
                  const SizedBox(width: 8.0),
                  Text(myGym['horario'] as String),
                ],
              ),
            // Add additional info rows here (e.g., amenities, website)
          ],
        ),
      ),
    );
  }
}
