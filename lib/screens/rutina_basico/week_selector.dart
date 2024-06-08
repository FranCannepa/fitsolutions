import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/Plan/ejercicio_create_dialogue.dart';
import 'package:fitsolutions/screens/rutina_basico/exercise_rows.dart';
import 'package:fitsolutions/screens/rutina_basico/header_row.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../modelo/models.dart';

class WeekSelector extends StatefulWidget {
  final Plan plan;
  const WeekSelector({super.key, required this.plan});

  @override
  State<WeekSelector> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
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
          week: widget.plan.idFromWeek(_selectedWeekIndex),
          nameController: nameController,
          descController: descController,
          durationController: durationController,
          pausaController: pausaController,
          serieController: repeticionController,
          repeticionController: serieController,
          cargaController: cargaController,
          dia: daysNames[_selectedDayIndex]),
    );
  }

  int _selectedWeekIndex = 0;
  int _selectedDayIndex = 0;

  final List<String> days = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
  final List<String> daysNames = [
    'Domingo',
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Vierens',
    'Sabado'
  ];

  void _addWeek(FitnessProvider fProv) {
    fProv.addWeek(widget.plan.weekCount() + 1, widget.plan);
  }

  void _removeWeek(FitnessProvider fProv) {
    fProv.deleteWeek(widget.plan);
  }

  @override
  Widget build(BuildContext context) {
    Logger log = Logger();
    final provider = context.watch<FitnessProvider>();
    final userData = context.read<UserData>();
    return Scaffold(
      appBar:
          AppBar(title: const Text('Rutina'), backgroundColor: Theme.of(context).colorScheme.primary),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Semana:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 32)),
                    if(!userData.esBasico()) ...[
                    InkWell(
                      onTap: () => {_removeWeek(provider)},
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color:Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.remove),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => {_addWeek(provider)},
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add),
                        ),
                      ),
                    )
                    ]
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50, // Adjust height according to your design
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.plan.weeks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedWeekIndex = index;
                            log.d('HI ITS $index');
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: index == _selectedWeekIndex
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: index == _selectedWeekIndex
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Dias:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (widget.plan.weekCount() > 0)
                  SizedBox(
                    height: 50, // Adjust height according to your design
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: index == _selectedDayIndex
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              days[index],
                              style: TextStyle(
                                color: index == _selectedDayIndex
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const HeaderRow(),
                if (widget.plan.weekCount() > 0)
                  ExerciseRows(
                      plan: widget.plan,
                      week: widget.plan.idFromWeek(_selectedWeekIndex),
                      day: daysNames[_selectedDayIndex],
                      fitnessProvider: provider)
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !userData.esBasico() ? ElevatedButton(
            onPressed: () => openNoteBox(null, provider),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20), // Adjust padding as needed
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 8, // Add shadow by setting elevation
              shadowColor: Colors.black.withOpacity(0.8),
            ), //placeholder
            child:  Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
          )
       : null,
    );
  }
}
