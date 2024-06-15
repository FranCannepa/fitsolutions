import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:flutter/material.dart';

import '../../modelo/models.dart';
//Nota seguramente no se necesite
class EjercicioInfoScreen extends StatefulWidget {
  final Ejercicio ejercicio;
  final FitnessProvider fitnessProvider;
  const EjercicioInfoScreen(
      {super.key, required this.ejercicio, required this.fitnessProvider});

  @override
  State<EjercicioInfoScreen> createState() => _EjercicioInfoScreenState();
}

class _EjercicioInfoScreenState extends State<EjercicioInfoScreen> {
  @override
  Widget build(BuildContext context) {
    Ejercicio ejercicio = widget.ejercicio;

    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      color: Colors.amber,
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Ejercicio: ${ejercicio.nombre}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Descripcion: ${ejercicio.descripcion}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Series: ${ejercicio.series}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 20), // Add some space between the fields
                  Expanded(
                    child: Text(
                      'Repeticiones: ${ejercicio.repeticiones}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Carga: ${ejercicio.carga} kg',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Ejecuccion: ${ejercicio.duracion}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 20), // Add some space between the fields
                  Expanded(
                    child: Text(
                      'Pausa: ${ejercicio.pausas} ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Cerrar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
