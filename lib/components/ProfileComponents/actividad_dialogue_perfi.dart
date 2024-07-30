import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivitiesDialog extends StatefulWidget {
  const ActivitiesDialog({super.key});

  @override
  State<ActivitiesDialog> createState() => _ActivitiesDialogState();
}

class _ActivitiesDialogState extends State<ActivitiesDialog> {
  DateTime? _selectedDate;

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

        var activities = snapshot.data!;
        
        // Filter activities by selected date
        if (_selectedDate != null) {
          activities = activities.where((activity) {
            final activityDate = activity.inicio.toDate();
            return activityDate.year == _selectedDate!.year &&
                   activityDate.month == _selectedDate!.month &&
                   activityDate.day == _selectedDate!.day;
          }).toList();
        }

        return AlertDialog(
          title: const Text('Actividades del Participante'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _selectedDate = selectedDate;
                          });
                        }
                      },
                      child: const Text('Seleccionar fecha'),
                    ),
                    if (_selectedDate != null)
                      Text(
                        'Fecha ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                      ),
                  ],
                  
                ),
                Expanded(
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
                                Text('Inicio: ${DateFormat().format(activity.inicio.toDate())}'),
                                Text('Fin: ${DateFormat().format(activity.fin.toDate())}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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

