import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivitiesDialog extends StatelessWidget {
  const ActivitiesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActividadProvider>();

    return FutureBuilder(
      future: provider.actividadesDeParticipante(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load activities: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return AlertDialog(
            title: const Text('SIN ACTIVIDADES'),
            content: const Text('No tienes inscripciones a Actividades'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        }

        final activities = snapshot.data!;

        return AlertDialog(
          title: const Text('Actividades del Participante'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    textColor: Colors.white,
                    title: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        DateTime.now().isAfter(activity.fin.toDate())
                            ? '${activity.nombre} TERMINADA'
                            : activity.nombre,
                        style: TextStyle(
                          fontWeight:
                              DateTime.now().isAfter(activity.fin.toDate())
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    subtitle: Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Theme.of(context).colorScheme.inversePrimary,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tipo: ${activity.tipo}'),
                          Text('Inicio: ${activity.inicio.toDate()}'),
                          Text('Fin: ${activity.fin.toDate()}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
