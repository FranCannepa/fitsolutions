import 'package:fitsolutions/modelo/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ActivityScatterChart extends StatelessWidget {
  final List<Actividad> activities;
  const ActivityScatterChart({super.key, required this.activities});
  /*
  titlesData: FlTitlesData(
      leftTitles: SideTitles(showTitles: true),
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (value) {
          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
          return '${date.day}/${date.month}';
        },
      ),
    ),
  */
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: activities.map((actividad) {
                final startHour = actividad.inicio.toDate().hour.toDouble();
                final finalHour = actividad.fin.toDate().hour.toDouble();
                final duration = finalHour - startHour;
                Logger().d('${actividad.nombre} $duration');
                return ScatterSpot(
                  duration.toDouble(),
                  actividad.participantes.toDouble(),
                );
              }).toList(),
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(reservedSize: 40, showTitles: true)),
                topTitles: AxisTitles(
                    sideTitles:
                        SideTitles(reservedSize: 40, showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 10,
                  sideTitles: SideTitles(
                    reservedSize: 40,
                    showTitles: true,
                  ),
                ),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(reservedSize: 40, showTitles: true)),
              ),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width - 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
            gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.primary
                ],
                begin: Alignment.centerRight,
                end: const Alignment(-1.0, -1.0)), //Gradient
          ),
          child: DataTable(
            columns: const [
              DataColumn(
                  label:
                      Text('Actividad', style: TextStyle(color: Colors.white))),
              DataColumn(
                  label: Center(
                child: Text('Participantes',
                    style: TextStyle(color: Colors.white)),
              )),
              DataColumn(
                  label: Center(
                child: Text('Duracion', style: TextStyle(color: Colors.white)),
              )),
            ],
            rows: activities.map((activity) {
              final startHour = activity.inicio.toDate().hour.toDouble();
              final finalHour = activity.fin.toDate().hour.toDouble();
              final duration = finalHour - startHour;
              return DataRow(cells: [
                DataCell(Text(activity.nombre,
                    style: const TextStyle(color: Colors.white))),
                DataCell(Center(
                    child: Text(activity.participantes.toString(),
                        style: const TextStyle(color: Colors.white)))),
                DataCell(Center(
                    child: Text(duration.toString(),
                        style: const TextStyle(color: Colors.white))))
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
