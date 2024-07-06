import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:fitsolutions/screens/Plan/ejercicio_create_dialogue.dart';
import 'package:fitsolutions/screens/rutina_basico/exercise_rows.dart';
import 'package:fitsolutions/screens/rutina_basico/header_row.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../modelo/models.dart';

class WeekSelector extends StatefulWidget {
  final Plan plan;
  final bool leading;
  const WeekSelector({super.key, required this.plan, required this.leading});

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

  bool isWeekCompleted = false; // Track week completion status
  bool isDayCompleted = false; // Track day completion status

  int _selectedWeekIndex = 0;
  int _selectedDayIndex = 0;
  bool? esBasico = true;
  Logger log = Logger();

  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    esUserBasico();
    _initializationFuture = initializeWorkout();
    setInitialSelectedWeek();
  }

  Future<void> initializeWorkout() async {
    await context
        .read<FitnessProvider>()
        .initializeWorkoutState(widget.plan, daysNames);
  }

  Future<bool> checkWeekCompletion(int weekIndex) async {
    // Fetch week completion status from Firestore and update state
    final provider = context.read<FitnessProvider>();
    return await provider.isWeekCompleted(widget.plan.idFromWeek(weekIndex));
  }

  Future<bool> checkDayCompletion(int weekIndex, int dayIndex) async {
    final provider = context.read<FitnessProvider>();
    return await provider.isDayCompleted(
        widget.plan.idFromWeek(weekIndex), daysNames[dayIndex]);
  }

  Future<void> setInitialSelectedWeek() async {
    final provider = context.read<FitnessProvider>();
    for (int i = 0; i < widget.plan.weeks.length; i++) {
      bool weekCompleted =
          await provider.isWeekCompleted(widget.plan.idFromWeek(i));
      if (!weekCompleted) {
        setState(() {
          _selectedWeekIndex = i;
        });
        break;
      }
    }
  }

  Future<void> esUserBasico() async {
    final prefs = SharedPrefsHelper();
    bool result = await prefs.esBasico();
    log.d('From week $result');
    setState(() {
      esBasico = result;
    });
  }

  final List<String> days = ['1', '2', '3', '4', '5', '6', '7'];
  final List<String> daysNames = [
    'Domingo',
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
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
    final provider = context.watch<FitnessProvider>();
    final userData = context.read<UserData>();

    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('La carga Inicial tomara un momento'),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: esBasico == false
                ? AppBar(
                    title: const Text('Rutina'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    automaticallyImplyLeading: widget.leading)
                : null,
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
                          if (!userData.esBasico()) ...[
                            InkWell(
                              onTap: () => {_removeWeek(provider)},
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
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
                        child: FutureBuilder<List<bool>>(
                            future: Future.wait(List.generate(
                                widget.plan.weeks.length,
                                (index) => checkWeekCompletion(index))),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<bool>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.plan.weeks.length,
                                itemBuilder: (BuildContext context, int index) {
                                  bool weekCompleted = snapshot.data![index];
                                  return GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _selectedWeekIndex = index;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: weekCompleted
                                            ? Colors.green
                                            : (index == _selectedWeekIndex
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          color: weekCompleted
                                              ? Colors.white
                                              : (index == _selectedWeekIndex
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
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
                            itemBuilder: (BuildContext context, int dayIndex) {
                              return FutureBuilder<bool>(
                                future: checkDayCompletion(
                                    _selectedWeekIndex, dayIndex),
                                builder: (BuildContext context,
                                    AsyncSnapshot<bool> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  bool dayCompleted = snapshot.data!;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDayIndex = dayIndex;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: dayCompleted
                                            ? Colors.green
                                            : (dayIndex == _selectedDayIndex
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        days[dayIndex],
                                        style: TextStyle(
                                          color: dayCompleted
                                              ? Colors.white
                                              : (dayIndex == _selectedDayIndex
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
            floatingActionButton: !userData.esBasico()
                ? ElevatedButton(
                    onPressed: () => openNoteBox(null, provider),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding:
                          const EdgeInsets.all(20), // Adjust padding as needed
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 8, // Add shadow by setting elevation
                      shadowColor: Colors.black.withOpacity(0.8),
                    ), //placeholder
                    child: Icon(Icons.add,
                        color: Theme.of(context).colorScheme.secondary),
                  )
                : null,
          );
        }
      },
    );
  }
}
