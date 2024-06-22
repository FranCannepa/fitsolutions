import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/components/CalendarComponents/calendario_actividad_agregar_dialog.dart';
import 'package:fitsolutions/components/CalendarComponents/calendario_displayer.dart';
import 'package:fitsolutions/components/CommonComponents/footer_bottom_navigator.dart';
import 'package:fitsolutions/modelo/Actividad.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure you have provider package imported

class HomeScreenContent extends StatelessWidget {
    final ActividadProvider actividadProvider;
  const HomeScreenContent({super.key, required this.actividadProvider});

  @override
  Widget build(BuildContext context) {
    final userProvider = 
        Provider.of<UserData>(context); // Access the UserData provider

return Scaffold(
      body: const CalendarioDisplayer(),
      /*bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.home,
      ),*/
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
