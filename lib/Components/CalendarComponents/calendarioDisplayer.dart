import 'package:fitsolutions/Components/CalendarComponents/calendarioActividadCard.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendarioAgregarActividadDialog.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendarioDiaActual.dart';
import 'package:fitsolutions/Components/CommonComponents/noDataError.dart';
import 'package:fitsolutions/Components/components.dart';
//import 'package:fitsolutions/Utilities/formaters.dart';
//import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'dart:developer';

class CalendarioDisplayer extends StatefulWidget {
  const CalendarioDisplayer({super.key});

  @override
  State<CalendarioDisplayer> createState() => _CalendarioDisplayerState();
}

class _CalendarioDisplayerState extends State<CalendarioDisplayer> {
  DateTime fechaSeleccionada = DateTime.now();
  List<Map<String, dynamic>> actividadesFetched = [];

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
    //final prefs = SharedPrefsHelper();
    final userProvider = context.read<UserData>();
    final fetchAction = userProvider.gimnasioId != '' ||
            userProvider.gimnasioIdPropietario != ''
        ? context.read<UserData>().fetchActividadesGimnasio(fechaSeleccionada)
        : context
            .read<UserData>()
            .fetchActividadesEntrenador(fechaSeleccionada);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchAction,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                actividadesFetched = snapshot.data!;
                return Center(
                  child: Column(
                    children: [
                      if (actividadesFetched.isEmpty)
                        const NoDataError(
                          message: "No quedan actividades por hoy",
                        )
                      else
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            DiaActual(),
                            SizedBox(
                              width: 10,
                            ),
                            ScreenTitle(title: "Actividades"),
                          ],
                        ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (fechaSeleccionada.isAfter(DateTime.now()))
                              ElevatedButton(
                                child: const Icon(Icons.arrow_back_ios),
                                onPressed: () => actividadesAnterior(),
                              ),
                            if (actividadesFetched.isNotEmpty)
                              ElevatedButton(
                                child: const Icon(Icons.arrow_forward_ios),
                                onPressed: () => actividadesSiguientes(),
                              ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: actividadesFetched.length,
                        itemBuilder: (context, index) {
                          final actividad = actividadesFetched[index];
                          return SizedBox(
                            child: CartaActividad(actividad: actividad),
                          );
                        },
                      ),
                      ElevatedButton(
                          onPressed: () => {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      CalendarioAgregarActividadDialog(
                                    propietarioActividadId: userProvider
                                        .gimnasioIdPropietario as String,
                                    onClose: () => Navigator.pop(context),
                                  ),
                                )
                              },
                          child: const Text("Nueva Actividad")),
                    ],
                  ),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
