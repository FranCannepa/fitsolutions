import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:fitsolutions/screens/Plan/ejercicio_create_dialogue.dart';
import 'package:fitsolutions/screens/rutina_basico/confirm_dialog.dart';
import 'package:fitsolutions/screens/rutina_basico/ejercicio_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExerciseRows extends StatefulWidget {
  final Plan plan;
  final String week;
  final String day;
  final FitnessProvider fitnessProvider;
  const ExerciseRows(
      {super.key,
      required this.plan,
      required this.week,
      required this.day,
      required this.fitnessProvider});

  @override
  State<ExerciseRows> createState() => _ExerciseRowsState();
}

class _ExerciseRowsState extends State<ExerciseRows> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController pausaController = TextEditingController();
  final TextEditingController serieController = TextEditingController();
  final TextEditingController repeticionController = TextEditingController();
  final TextEditingController cargaController = TextEditingController();

  final Map<String, bool> _checkedExercises = {};

  void updateExerciseState(
      String exerciseId, bool completed, String day) async {
    await widget.fitnessProvider
        .updateExerciseCompletion(widget.week, exerciseId, completed, day);
  }

  void openNoteBox(String? docId, FitnessProvider fitnessProvider) {
    showDialog(
      context: context,
      builder: (context) => EjercicioCreateDialogue(
          fitnessProvider: fitnessProvider,
          docId: docId,
          plan: widget.plan,
          week: widget.week,
          nameController: nameController,
          descController: descController,
          durationController: durationController,
          pausaController: pausaController,
          serieController: repeticionController,
          repeticionController: serieController,
          cargaController: cargaController,
          dia: widget.day),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.fitnessProvider
        .initializeCheckBox(widget.week)
        .then((Map<String, bool> values) {
      setState(() {
        _checkedExercises.addAll(values);
      });
    });
  }

  Future<List<Widget>> buildEjercicioCards(
      Plan plan, String week, String dia, UserData userData) async {
    final ejercicios =
        await widget.fitnessProvider.getEjerciciosDelDiaList(plan, week, dia);
    return ejercicios.map((ejercicio) {
      _checkedExercises[ejercicio.id] =
          _checkedExercises[ejercicio.id] ?? false;
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return EjercicioDialog(ejercicio: ejercicio);
            },
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (userData.esBasico()) ...[
                  Checkbox(
                    value: _checkedExercises[ejercicio.id],
                    onChanged: (bool? value) {
                      setState(() {
                        _checkedExercises[ejercicio.id] = value!;
                        updateExerciseState(ejercicio.id, value, widget.day);
                      });
                    },
                  ),
                ],
                Expanded(
                    child: Text(ejercicio.nombre, textAlign: TextAlign.left)),
                Expanded(
                    child: Text(ejercicio.series.toString(),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text(ejercicio.repeticiones.toString(),
                        textAlign: TextAlign.center)),
                Expanded(
                    child: Text(ejercicio.carga.toString(),
                        textAlign: TextAlign.center)),
                Expanded(
                    child:
                        Text(ejercicio.duracion, textAlign: TextAlign.center)),
                const SizedBox(width: 20),
                Expanded(
                    child:
                        Text(ejercicio.pausas!, textAlign: TextAlign.center)),
                if (!userData.esBasico()) ...[
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => {
                      {
                        nameController.text = ejercicio.nombre,
                        descController.text = ejercicio.descripcion,
                        serieController.text = ejercicio.series.toString(),
                        repeticionController.text =
                            ejercicio.repeticiones.toString(),
                        cargaController.text = ejercicio.carga.toString(),
                        durationController.text = ejercicio.duracion.toString(),
                        pausaController.text = ejercicio.pausas.toString(),
                        openNoteBox(ejercicio.id, widget.fitnessProvider)
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmDialog(
                                title: 'Eliminar Ejercicio',
                                content: '¿Eliminar el Ejercicio?',
                                onConfirm: () async {
                                  await widget.fitnessProvider.deleteEjercicio(
                                      plan, widget.week, ejercicio.id);
                                },
                                parentKey: null);
                          })
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserData>();
    return FutureBuilder<List<Widget>>(
      future:
          buildEjercicioCards(widget.plan, widget.week, widget.day, userData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             NoDataError(message: 'No hay Ejercicios para este dia'),
            ],
          );
        } else {
          return Flexible(
            fit: FlexFit.loose,
            child: ListView(
              shrinkWrap: true,
              children: snapshot.data!,
            ),
          );
        }
      },
    );
  }
}
