import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AgeDistributionPieChart extends StatelessWidget {
  final Map<String, int> ageCategories;

  const AgeDistributionPieChart({super.key, required this.ageCategories});

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = ageCategories.entries.map((entry) {
      return PieChartSectionData(
        title: '${entry.key}\n(${entry.value})',
        value: entry.value.toDouble(),
        color: getColorForAgeCategory(entry.key),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 4,
      ),
    );
  }

  Color getColorForAgeCategory(String ageCategory) {
    switch (ageCategory) {
      case '0-18':
        return Colors.blue;
      case '19-25':
        return Colors.green;
      case '26-35':
        return Colors.orange;
      case '36-45':
        return Colors.purple;
      case '46-60':
        return Colors.red;
      case '60+':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}