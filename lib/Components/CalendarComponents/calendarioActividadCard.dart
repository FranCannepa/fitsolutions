import 'package:fitsolutions/Components/CalendarComponents/calendarioActividadDialog.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:flutter/material.dart';

class CartaActividad extends StatelessWidget {
  late Map<String, dynamic> actividad;

  CartaActividad({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ActividadDialog(
              actividad: actividad,
              onClose: () => Navigator.pop(context),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actividad['nombreActividad'],
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 16),
                  Text(
                    Formatters().formatTimestampTime(actividad['inicio']),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Text(' - '),
                  Text(
                    Formatters().formatTimestampTime(actividad['fin']),
                    style: const TextStyle(fontSize: 20),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
