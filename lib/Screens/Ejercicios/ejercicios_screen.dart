//import 'package:fitsolutions/Components/components.dart'; // Assuming ejercicios_card.dart contains EjerciciosCards
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/rutina_basico/workout_schedule.dart';
//import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EjerciciosScreen extends StatelessWidget {
  const EjerciciosScreen({super.key});

  Future<Plan?> getPlanFromUser(FitnessProvider provider) async {
    final prefs = SharedPrefsHelper();
    String? docId = await prefs.getUserId();
    return await provider.getRutinaDeUsuario(docId!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FitnessProvider>();
    return FutureBuilder(
      future: getPlanFromUser(provider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("El usuario no tiene rutina asignada"),
            ),
          );
        } else {
          // Render your UI based on the result of the asynchronous operation
          return WorkoutSchedule(plan: snapshot.data!,leading: false);
        }
      },
    );
  }
}
