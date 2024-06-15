import 'dart:developer';

import 'package:fitsolutions/Components/CommonComponents/noDataError.dart';
import 'package:fitsolutions/Components/DietasComponents/dietaGestor.dart';
import 'package:fitsolutions/Components/DietasComponents/dieta_card.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietaAdministrador extends StatefulWidget {
  const DietaAdministrador({super.key});

  @override
  State<DietaAdministrador> createState() => _DietaAdministradorState();
}

class _DietaAdministradorState extends State<DietaAdministrador> {
  @override
  Widget build(BuildContext context) {
    final dietaProvider = context.watch<DietaProvider>();
    return Container(
      child: FutureBuilder(
          future: dietaProvider.getDietas(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const NoDataError(message: "No tiene Dietas Creadas");
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Dieta?> misDietas = snapshot.data!;
              return DietaGestor(dietas: misDietas);
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
