import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
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
    if (_selectedWeekIndex != -1) {
      showDialog(
        context: context,
        builder: (context) => EjercicioCreateDialogue(
            fitnessProvider: fitnessProvider,
            docId: docId,
            plan: widget.plan,
            week: widget.plan.idFromWeek(_selectedWeekIndex!),
            nameController: nameController,
            descController: descController,
            durationController: durationController,
            pausaController: pausaController,
            serieController: repeticionController,
            repeticionController: serieController,
            cargaController: cargaController,
            dia: daysNames[_selectedDayIndex]),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No existen semanas'),
          content:
              const Text('Debe crear una semana para poder agregar ejercicios'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool isWeekCompleted = false; // Track week completion status
  bool isDayCompleted = false; // Track day completion status
  int? _selectedWeekIndex;
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
    setState(() {
      _selectedWeekIndex = widget.plan.weekCount() - 1;
    });
  }

  Future<void> initializeWorkout() async {
    final userData = context.read<UserData>();
    if (userData.esBasico()) {
      await context
          .read<FitnessProvider>()
          .initializeWorkoutState(widget.plan, daysNames);
    }
  }

  Future<bool> checkWeekCompletion(int weekIndex) async {
    // Fetch week completion status from Firestore and update state
    final userData = context.read<UserData>();
    if (userData.esBasico()) {
      final provider = context.read<FitnessProvider>();
      return await provider.isWeekCompleted(widget.plan.idFromWeek(weekIndex));
    }
    return false;
  }

  Future<bool> checkDayCompletion(int weekIndex, int dayIndex) async {
    final userData = context.read<UserData>();
    if (userData.esBasico()) {
      final provider = context.read<FitnessProvider>();
      return await provider.isDayCompleted(
          widget.plan.idFromWeek(weekIndex), daysNames[dayIndex]);
    }
    return false;
  }

  Future<void> setInitialSelectedWeek() async {
    final provider = context.read<FitnessProvider>();
    final userData = context.read<UserData>();
    if (userData.esBasico()) {
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
  final List<String> daysNames = ['1', '2', '3', '4', '5', '6', '7'];

  void _addWeek(FitnessProvider fProv) async {
    await fProv.addWeek(widget.plan.weekCount() + 1, widget.plan);
    setState(() {
      _selectedWeekIndex = widget.plan.weekCount() - 1;
    });
  }

  void _removeWeek(FitnessProvider fProv) async {
    if (_selectedWeekIndex != -1) {
      await fProv.deleteWeek(widget.plan);
      setState(() {
        _selectedWeekIndex = widget.plan.weekCount() - 1;

      });
    }
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
                    iconTheme: const IconThemeData(
                      color: Colors.white, // Set the back arrow color here
                    ),
                    backgroundColor: Colors.black,
                    title: Text(
                      widget.plan.name,
                      style: const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
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
                                  bool weekCompleted = snapshot.data!.length ==
                                          widget.plan.weeks.length
                                      ? snapshot.data![index]
                                      : false;
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
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Text('Dia:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 32)),
                          Spacer(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if(_selectedWeekIndex != -1)
                      SizedBox(
                        height: 50, // Adjust height according to your design
                        child: FutureBuilder<List<bool>>(
                            future: Future.wait(List.generate(
                                days.length,
                                (index) => checkDayCompletion(
                                    _selectedWeekIndex!, index))),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<bool>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: days.length,
                                itemBuilder: (BuildContext context, int index) {
                                  bool dayCompleted =
                                      snapshot.data!.length == days.length
                                          ? snapshot.data![index]
                                          : false;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDayIndex = index;
                                        // Reset day completion status when switching days
                                        isDayCompleted = dayCompleted;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: dayCompleted
                                            ? Colors.green
                                            : (index == _selectedDayIndex
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
                                        daysNames[index],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                const HeaderRow(),
                if (widget.plan.weekCount() > 0 && _selectedWeekIndex != -1)
                  Expanded(
                    child: ExerciseRows(
                      plan: widget.plan,
                      week: widget.plan.idFromWeek(_selectedWeekIndex!),
                      day: days[_selectedDayIndex],
                      fitnessProvider: provider,
                    ),
                  ),
              ],
            ),
            floatingActionButton: !userData.esBasico()
                ? FloatingActionButton(
                    onPressed: () => openNoteBox(null, provider),
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
