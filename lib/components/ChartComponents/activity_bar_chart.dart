import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../modelo/models.dart';

class ActivityBarChart extends StatelessWidget {
  final List<Actividad> activities;

  const ActivityBarChart({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
   
    activities.sort((a, b) => b.participantes.compareTo(a.participantes));

    
    final mostPopularActivity = activities.first;
    final leastPopularActivity = activities.last;

    List<BarChartGroupData> barGroups = activities.map((activity) {
      Color barColor;
      if (activity == mostPopularActivity) {
        barColor = Colors.green;
      } else if (activity == leastPopularActivity) {
        barColor = Colors.red;
      } else {
        barColor = Theme.of(context)
            .colorScheme
            .tertiary; 
      }

      return BarChartGroupData(
        x: activity.id.hashCode,
        barRods: [
          BarChartRodData(
            toY: activity.participantes.toDouble(),
            color: barColor,
          )
        ],
        showingTooltipIndicators: [],
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              barTouchData: barTouchData,
              barGroups: barGroups,
              backgroundColor: Colors.black87,
              gridData: const FlGridData(show: false),
              alignment: BarChartAlignment.spaceEvenly,
              groupsSpace: 10,
              maxY: activities
                      .map((a) => a.participantes.toDouble())
                      .reduce((a, b) => a > b ? a : b) +
                  5, 
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
                    showTitles: false,
                  ),
                ),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(reservedSize: 40, showTitles: true)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height - 400,
          width: MediaQuery.of(context).size.width - 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), 
              ),
            ],
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(
                      label: Text('Actividad',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20))),
                  DataColumn(
                      label: Text('Participantes',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20))),
                ],
                rows: activities.map((activity) {
                  return DataRow(cells: [
                    DataCell(Text(activity.nombre,
                        style: const TextStyle(
                          color: Colors.black,
                        ))),
                    DataCell(Text(activity.participantes.toString(),
                        style: const TextStyle(color: Colors.black))),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );
}
