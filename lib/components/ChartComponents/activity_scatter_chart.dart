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
        DataTable(
          columns: const [
            DataColumn(label: Text('Activity')),
            DataColumn(label: Text('Participants')),
            DataColumn(label: Text('Duration')),
          ],
          rows: activities.map((activity) {
            final startHour = activity.inicio.toDate().hour.toDouble();
            final finalHour = activity.fin.toDate().hour.toDouble();
            final duration = finalHour - startHour;
            return DataRow(cells: [
              DataCell(Text(activity.nombre)),
              DataCell(Text(activity.participantes.toString())),
              DataCell(Text(duration.toString())),
            ]);
          }).toList(),
        ),
      ],
    );
  }
}
