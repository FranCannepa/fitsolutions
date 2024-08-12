import 'package:fitsolutions/modelo/ejercicio.dart';
import 'package:flutter/material.dart';



class EjercicioDialog extends StatelessWidget {
  final Ejercicio ejercicio;

  const EjercicioDialog({super.key, required this.ejercicio});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        ejercicio.nombre,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
      ),
      content: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).dialogBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Descripción', ejercicio.descripcion),
            _buildDetailRow('Series', ejercicio.series.toString()),
            _buildDetailRow('Repeticiones', ejercicio.repeticiones.toString()),
            _buildDetailRow('Carga', '${ejercicio.carga} kg'),
            _buildDetailRow('Duración', '${ejercicio.duracion} min'),
            _buildDetailRow('Pausas', ejercicio.pausas == '' ? 'Sin Pausas' : '${ejercicio.pausas} min'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}