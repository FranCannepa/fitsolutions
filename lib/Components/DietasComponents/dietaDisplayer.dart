import 'package:fitsolutions/Components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/Components/DietasComponents/dieta_card.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietaDisplayer extends StatefulWidget {
  const DietaDisplayer({super.key});

  @override
  State<DietaDisplayer> createState() => _DietaDisplayerState();
}

class _DietaDisplayerState extends State<DietaDisplayer> {
  @override
  Widget build(BuildContext context) {
    final dietaProvider = context.watch<DietaProvider>();
    return FutureBuilder(
        future: dietaProvider.getDieta(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const NoDataError(message: "No tiene Dietas Asignadas");
          }
          if (snapshot.hasData) {
            Dieta miDieta = snapshot.data!;
            return Column(
              children: [DietaCard(dieta: miDieta)],
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
