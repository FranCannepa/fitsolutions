import 'package:fitsolutions/components/CalendarComponents/calendario_actividad_agregar_dialog.dart';
import 'package:fitsolutions/components/CalendarComponents/calendario_displayer.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:fitsolutions/screens/Notification/notification_bell.dart';
import 'package:fitsolutions/screens/rutina_basico/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/welcome_screen.dart';

class HomeScreenContent extends StatelessWidget {
  final ActividadProvider actividadProvider;
  const HomeScreenContent({super.key, required this.actividadProvider});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserData>(context);
    return Scaffold(
      body: const CalendarioDisplayer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        automaticallyImplyLeading: false,
        actions: [
          const NotificationBell(),
          IconButton(
            onPressed: () async {
              UserProvider userProvider = context.read<UserProvider>();
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmDialog(
                        title: 'Cerrar Sesion',
                        content: '¿Desea Cerrar Sesion?',
                        onConfirm: () async {
                          await userProvider.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const WelcomePage(),
                              ),
                            );
                          }
                        },
                        parentKey: null);
                  });
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 30,),
          ),
        ],
      ),
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
