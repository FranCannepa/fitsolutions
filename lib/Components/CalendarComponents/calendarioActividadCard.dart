import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/modelo/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartaActividad extends StatelessWidget {
  late Map<String, dynamic> actividad;

  CartaActividad({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserData>();
    return Card(
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _buildDetailedInfoDialog(actividad),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actividad['nombreActividad'],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  Text(
                    Formatters().extractDate(actividad['inicio']),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.timer, size: 16),
                  Text(
                    Formatters().formatTimestampTime(actividad['inicio']),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Text(' - '),
                  Text(
                    Formatters().formatTimestampTime(actividad['fin']),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDetailedInfoDialog(Map<String, dynamic> actividad) { 
  return AlertDialog(
    title: Text(actividad['nombreActividad']),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            Text(
              Formatters().extractDate(actividad['inicio']),
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            const Icon(Icons.timer, size: 16),
            Text(
              Formatters().formatTimestampTime(actividad['inicio']),
              style: const TextStyle(fontSize: 14),
            ),
            const Text(' - '),
            Text(
              Formatters().formatTimestampTime(actividad['fin']),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        const SizedBox(height: 16.0),
        if (UserData().esBasico())
          ElevatedButton(
            onPressed: () {
              
            },
            child: const Text('Inscribirse'),
          ),
      ],
    ),
  );
}

}
