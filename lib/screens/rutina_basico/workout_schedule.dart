import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/screens/rutina_basico/week_selector.dart';
import 'package:flutter/material.dart';

class WorkoutSchedule extends StatefulWidget {
  final Plan plan;
  const WorkoutSchedule({super.key, required this.plan});

  @override
  State<WorkoutSchedule> createState() => _WorkoutScheduleState();
}

class _WorkoutScheduleState extends State<WorkoutSchedule> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WeekSelector(
      plan: widget.plan,
    ));
  }
}
