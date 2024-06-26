import 'package:fitsolutions/components/CalendarComponents/calendario_actividad_agregar_dialog.dart';
import 'package:fitsolutions/components/CalendarComponents/calendario_displayer.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreenContent extends StatelessWidget {
  final ActividadProvider actividadProvider;
  const HomeScreenContent({super.key, required this.actividadProvider});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserData>(context);
    return Scaffold(
      body: const CalendarioDisplayer(),
      floatingActionButton: userProvider.esBasico()
          ? null
          : FloatingActionButton(
              heroTag: 'unique2',
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) => CalendarioAgregarActividadDialog(
                    onClose: () => Navigator.pop(context),
                    propietarioActividadId: userProvider.origenAdministrador,
                    actividadProvider: actividadProvider,
                  ),
                )
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
