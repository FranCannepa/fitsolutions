import 'package:fitsolutions/Components/CalendarComponents/calendario_actividad_dialog.dart';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:flutter/material.dart';

class CartaActividad extends StatelessWidget {
  final Actividad actividad;

  const CartaActividad({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actividad.nombre,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 16),
                  Text(
                    Formatters().formatTimestampTime(actividad.inicio),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Text(' - '),
                  Text(
                    Formatters().formatTimestampTime(actividad.fin),
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
