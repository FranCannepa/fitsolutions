import 'dart:developer';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/components/CalendarComponents/calendario_actividad_card.dart';
import 'package:fitsolutions/components/CalendarComponents/calendario_dia_actual.dart';
import 'package:fitsolutions/components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarioDisplayer extends StatefulWidget {
  const CalendarioDisplayer({super.key});

  @override
  State<CalendarioDisplayer> createState() => _CalendarioDisplayerState();
}

class _CalendarioDisplayerState extends State<CalendarioDisplayer> {
  DateTime fechaSeleccionada = DateTime.now();
  late List<Actividad> actividadesFetched;

  void actividadesSiguientes() {
    setState(() {
      fechaSeleccionada = fechaSeleccionada.add(const Duration(days: 1));
    });
  }

  void actividadesAnterior() {
    setState(() {
      fechaSeleccionada = fechaSeleccionada.subtract(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final actividadesProvider = context.watch<ActividadProvider>();
    final UserData userProvider = context.read<UserData>();
    userProvider.initializeData();
    return FutureBuilder<List<Actividad>>(
      future: actividadesProvider.fetchActividades(fechaSeleccionada),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return Center(
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DiaActual(
                        fecha: fechaSeleccionada,
                      ),
                      const SizedBox(width: 20),
                      const ScreenTitle(title: "Actividades"),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15.0),
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (fechaSeleccionada.isAfter(DateTime.now()))
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onPressed: () => actividadesAnterior(),
                        ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () => actividadesSiguientes(),
                      ),
                    ],
                  ),
                ),
                if (snapshot.data!.isNotEmpty)
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...snapshot.data!.map(
                            (actividad) => CartaActividad(actividad: actividad),
                          ),
                        ],
                      ),
                    ),
                  ))
                else
                  Container(
                    margin: const EdgeInsets.only(top: 200.0),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        NoDataError(message: "No quedan actividades por hoy"),
                      ],
                    ),
                  )
              ],
            ),
          );
        } else {
          return Text('Error: ${snapshot.error}');
        }
      },
    );
  }
}
