
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/Plan/ejercicio_create_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgregarEjercicioScreen extends StatefulWidget {
  final Plan plan;
  final String dia;
  final String week;
  const AgregarEjercicioScreen({super.key, required this.plan,required this.week, required this.dia});

  @override
  State<AgregarEjercicioScreen> createState() => _AgregarEjercicioScreenState();
}

class _AgregarEjercicioScreenState extends State<AgregarEjercicioScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController pausaController = TextEditingController();
  final TextEditingController serieController = TextEditingController();
  final TextEditingController repeticionController = TextEditingController();
  final TextEditingController cargaController = TextEditingController();

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
          dia: widget.dia),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FitnessProvider fitnessProvider = context.watch<FitnessProvider>();
    return Scaffold(
        floatingActionButton: ElevatedButton(
          onPressed: () => openNoteBox(null, fitnessProvider), //placeholder
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List<Ejercicio>>(
            future: fitnessProvider.getEjerciciosDelDiaList(widget.plan,widget.week,widget.dia),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Este dia no tiene Ejercicios'));
              } else {
                final ejercicios = snapshot.data!;
                return ListView.builder(
                    itemCount: ejercicios.length,
                    itemBuilder: (context, index) {
                      final ejercicio = ejercicios[index];
                      return ListTile(
                        title: Text(ejercicio.nombre),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () => {
                                      nameController.text = ejercicio.nombre,
                                      descController.text = ejercicio.descripcion,
                                      serieController.text = ejercicio.series.toString(),
                                      repeticionController.text = ejercicio.repeticiones.toString(),
                                      cargaController.text = ejercicio.carga.toString(),
                                      durationController.text = ejercicio.duracion.toString(),
                                      pausaController.text = ejercicio.pausas.toString(),
                                      openNoteBox(ejercicio.id, fitnessProvider)
                                    },
                                icon: const Icon(Icons.settings)),
                            IconButton(
                                onPressed: () =>
                                    //add a do you wish to delete
                                    fitnessProvider.deleteEjercicio(widget.plan,ejercicio.id),
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                        onTap: () => {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.75,
                                color: Colors.amber,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Nombre del Plan: ${ejercicio.nombre}'),
                                      Text(
                                        'Descripcion: ${ejercicio.nombre}',
                                      ),
                                      Text(
                                        'Peso minimo: ${ejercicio.nombre} kilogramos',
                                      ),
                                      Text(
                                        'Peso maxima: ${ejercicio.nombre} kilogramos',
                                      ),
                                      Text(
                                        'Altura minima: ${ejercicio.nombre} metros',
                                      ),
                                      Text(
                                        'Altura maxima: ${ejercicio.nombre} metros',
                                      ),
                                      ElevatedButton(
                                        child: const Text('Cerrar'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        },
                      );
                    });
              }
            }));
  }
}
