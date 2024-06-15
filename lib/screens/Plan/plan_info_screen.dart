import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/rutina_basico/workout_schedule.dart';
import 'package:flutter/material.dart';

import '../../modelo/models.dart';

class PlanInfoScreen extends StatefulWidget {
  final Plan plan;
  final FitnessProvider fitnessProvider;
  const PlanInfoScreen(
      {super.key, required this.plan, required this.fitnessProvider});

  @override
  State<PlanInfoScreen> createState() => _PlanInfoScreenState();
}

class _PlanInfoScreenState extends State<PlanInfoScreen> {
  @override
  Widget build(BuildContext context) {
    Plan plan = widget.plan;

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
                  'Plan: ${plan.name}',
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
                  'Descripcion: ${plan.description}',
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
                      'Peso mínimo: ${plan.weight.entries.elementAt(0).value} kilogramos',
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
                      'Peso máximo: ${plan.weight.entries.elementAt(1).value} kilogramos',
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
                      'Altura mínima: ${plan.height.entries.elementAt(0).value} cm',
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
                      'Altura máxima: ${plan.height.entries.elementAt(1).value} cm',
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
                child: const Text('Gestionar rutina semanal'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkoutSchedule(plan: plan,leading: true)),
                ),
              ),
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
