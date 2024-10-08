import 'package:fitsolutions/Components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/Components/DietasComponents/dieta_gestor.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/components/CommonComponents/screen_upper_title.dart';
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
    return Column(
      children: [
        const ScreenUpperTitle(title: "Gestor Dietas"),
        Expanded(
            child: Center(
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
        ))
      ],
    );
  }
}
