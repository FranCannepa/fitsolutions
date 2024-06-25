import 'package:fitsolutions/Components/CalendarComponents/calendario_agregar_actividad_dialog.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendario_displayer.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();
    return Scaffold(
      body: const CalendarioDisplayer(),
      bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.home,
      ),
      floatingActionButton: userProvider.esBasico()
          ? null
          : FloatingActionButton(
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) => CalendarioAgregarActividadDialog(
                    onClose: () => Navigator.pop(context),
                    propietarioActividadId: userProvider.origenAdministrador,
                  ),
                )
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
