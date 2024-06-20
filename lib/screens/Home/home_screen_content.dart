import 'package:fitsolutions/components/CalendarComponents/calendario_agregar_actividad_dialog.dart';
import 'package:fitsolutions/components/CalendarComponents/calendario_displayer.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure you have provider package imported

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserData>(context); // Access the UserData provider

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.topRight, // Align the button to the bottom right corner
                margin: const EdgeInsets.all(16), // Adjust margin as needed
              ),
              const CalendarioDisplayer(),
              // Add the bottom navigation bar here
            ],
          ),
        ),
        if (!userProvider.esBasico())
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'uniqueTag', // Assign a unique hero tag
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
          ),
      ],
    );
  }
}
