import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/Plan/plan_days_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeeklyActivities extends StatefulWidget {
  final Plan plan;
  const WeeklyActivities({super.key, required this.plan});

  @override
  State<WeeklyActivities> createState() => _WeeklyActivitiesState();
}

class _WeeklyActivitiesState extends State<WeeklyActivities> {
  void _addWeek(FitnessProvider fProv) {
    fProv.addWeek(widget.plan.weekCount() + 1, widget.plan);
  }

  void _removeWeek(FitnessProvider fProv) {
    fProv.deleteWeek(widget.plan);
  }

  @override
  Widget build(BuildContext context) {
    final fProvider = context.watch<FitnessProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Semana',
                style: TextStyle(
                  fontFamily: 'Inter',
                  letterSpacing: 0,
                  fontSize: 30,
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () => {_removeWeek(fProvider)},
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.remove),
                  ),
                ),
              ),
              InkWell(
                onTap: () => {_addWeek(fProvider)},
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
          for (int i = 1; i <= widget.plan.weekCount(); i++)
            InkWell(
              onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  PlanDaysScreen(plan:widget.plan,week: widget.plan.idFromWeek(i))),
                        );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                  child: Text(
                    '$i',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
