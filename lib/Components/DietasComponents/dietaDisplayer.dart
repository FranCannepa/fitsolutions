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
    return Center(
      child: FutureBuilder<Dieta?>(
        future: dietaProvider.getDieta(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            Dieta miDieta = snapshot.data!;
            return DietaCard(dieta: miDieta);
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const NoDataError(message: "No tiene Dietas Asignadas");
          }
          return Container();
        },
      ),
    );
  }
}
