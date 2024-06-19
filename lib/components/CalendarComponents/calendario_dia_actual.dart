import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiaActual extends StatelessWidget {
  final DateTime fecha;

  const DiaActual({super.key, required this.fecha});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('d').format(fecha);

    final monthMap = {
      1: 'Enero',
      2: 'Febrero',
      3: 'Marzo',
      4: 'Abril',
      5: 'Mayo',
      6: 'Junio',
      7: 'Julio',
      8: 'Agosto',
      9: 'Septiembre',
      10: 'Octubre',
      11: 'Noviembre',
      12: 'Diciembre',
    };

    final month = monthMap[fecha.month];

    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              day,
              style: const TextStyle(
                fontSize: 36.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              month!,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
