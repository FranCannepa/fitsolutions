import 'package:fitsolutions/modelo/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ActivityPieChart extends StatelessWidget {
  final List<Actividad> activities;
  const ActivityPieChart({super.key, required this.activities});
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
    return PieChart(
      PieChartData(
        sections: activities
            .fold<Map<String, double>>({}, (acc, actividad) {
              acc[actividad.tipo] = (acc[actividad.tipo] ?? 0) + 1;
              return acc;
            })
            .entries
            .map((entry) {
              return PieChartSectionData(
                color: Colors
                    .primaries[entry.key.hashCode % Colors.primaries.length],
                value: entry.value,
                title: '${entry.key}: ${entry.value}',
                radius: 50,
              );
            })
            .toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
