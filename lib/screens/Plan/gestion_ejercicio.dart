import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/Plan/gestion_ejercicio_create_dialogue.dart';
import 'package:fitsolutions/screens/rutina_basico/confirm_dialog.dart';
import 'package:fitsolutions/screens/rutina_basico/ejercicio_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EjercicioSistemaScreen extends StatefulWidget {
  const EjercicioSistemaScreen({super.key});

  @override
  State<EjercicioSistemaScreen> createState() => _EjercicioSistemaScreenState();
}

class _EjercicioSistemaScreenState extends State<EjercicioSistemaScreen> {
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
        builder: (context) => EjercicioCreateDialogueAdmin(
              fitnessProvider: fitnessProvider,
              docId: docId,
              nameController: nameController,
              descController: descController,
              durationController: durationController,
              pausaController: pausaController,
              serieController: repeticionController,
              repeticionController: serieController,
              cargaController: cargaController,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final FitnessProvider fitnessProvider = context.watch<FitnessProvider>();
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: const Text(
              'Ejercicios',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => openNoteBox(null, fitnessProvider),
            child:
                Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
          ),
          body: FutureBuilder<List<Ejercicio>>(
              future: fitnessProvider.getEjercicios(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: NoDataError(
                          message: 'Aun no se han creado Ejercicios'));
                } else {
                  final ejercicios = snapshot.data!;

                  return ListView.builder(
                      itemCount: ejercicios.length,
                      itemBuilder: (context, index) {
                        final ejercicio = ejercicios[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              ejercicio.nombre.toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).cardColor),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () => {
                                          nameController.text =
                                              ejercicio.nombre,
                                          descController.text =
                                              ejercicio.descripcion,
                                          serieController.text =
                                              ejercicio.series.toString(),
                                          repeticionController.text =
                                              ejercicio.repeticiones.toString(),
                                          cargaController.text =
                                              ejercicio.carga.toString(),
                                          durationController.text =
                                              ejercicio.duracion.toString(),
                                          pausaController.text =
                                              ejercicio.pausas.toString(),
                                          openNoteBox(
                                              ejercicio.id, fitnessProvider)
                                        },
                                    icon: const Icon(Icons.settings)),
                                IconButton(
                                    onPressed: () => {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ConfirmDialog(
                                                    title: 'Borrar Ejercicio',
                                                    content:
                                                        '¿Borrar el Ejercicio (No sera eliminado de Rutinas)?',
                                                    onConfirm: () async {
                                                      fitnessProvider
                                                          .deleteEjercicioCollection(
                                                              ejercicio.id);
                                                    },
                                                    parentKey: null);
                                              })
                                        },
                                    icon: const Icon(Icons.delete)),
                              ],
                            ),
                            onTap: () => {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return EjercicioDialog(
                                        ejercicio: ejercicio);
                                  })
                            },
                          ),
                        );
                      });
                }
              })),
    );
  }
}
