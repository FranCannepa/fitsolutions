import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:fitsolutions/components/ChartComponents/activity_age_distribution_pie_chart.dart';
import 'package:fitsolutions/components/ChartComponents/activity_bar_chart.dart';
import 'package:fitsolutions/components/ChartComponents/activity_pie_chart.dart';
import 'package:fitsolutions/components/ChartComponents/activity_scatter_chart.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChartDisplay extends StatefulWidget {
  const ChartDisplay({super.key});

  @override
  State<ChartDisplay> createState() => _ChartDisplayState();
}

class _ChartDisplayState extends State<ChartDisplay> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('METRICAS DEL GIMNASIO')),
      body: FutureBuilder<List<Actividad>>(
        future: provider.getAllActivities(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Actividad> activities = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenSubTitle(
                      text: 'Cantidad participantes en cada Actividad'),
                  const SizedBox(height: 16),
                  Container(
                    height: 800,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.tertiaryContainer),
                    child: ActivityBarChart(activities: activities),
                  ),
                  const SizedBox(height: 50),
                  const ScreenSubTitle(text: 'Distribucion Tipos de Actividad'),
                  const SizedBox(height: 30),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.tertiaryContainer),
                    child: ActivityPieChart(activities: activities),
                  ),
                  const SizedBox(height: 50),
                  const ScreenSubTitle(
                      text: 'Duracion de Actvidiad vs Participantes'),
                  Container(
                    height: 800,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.tertiaryContainer),
                    child: ActivityScatterChart(activities: activities),
                  ),
                  const ScreenSubTitle(
                      text: 'Distribucion de Edades por Actividad'),
                  const SizedBox(height: 30),
                  FutureBuilder<List<UsuarioBasico>>(
                      future: provider.getAllParticipants(),
                      builder: (context, participantSnapshot) {
                        if (!participantSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        List<UsuarioBasico> participants =
                            participantSnapshot.data!;
                        Map<String, int> ageCategories =
                            categorizeAges(participants);
                        return Container(
                          height: 200,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer),
                          child: AgeDistributionPieChart(
                              ageCategories: ageCategories),
                        );
                      })
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, int> categorizeAges(List<UsuarioBasico> participants) {
    Map<String, int> ageCategories = {
      '0-18': 0,
      '19-25': 0,
      '26-35': 0,
      '36-45': 0,
      '46-60': 0,
      '60+': 0,
    };

    for (var participant in participants) {
      int age = participant.getAge();
      if (age <= 18) {
        ageCategories['0-18'] = ageCategories['0-18']! + 1;
      } else if (age <= 25) {
        ageCategories['19-25'] = ageCategories['19-25']! + 1;
      } else if (age <= 35) {
        ageCategories['26-35'] = ageCategories['26-35']! + 1;
      } else if (age <= 45) {
        ageCategories['36-45'] = ageCategories['36-45']! + 1;
      } else if (age <= 60) {
        ageCategories['46-60'] = ageCategories['46-60']! + 1;
      } else {
        ageCategories['60+'] = ageCategories['60+']! + 1;
      }
    }

    return ageCategories;
  }
}
