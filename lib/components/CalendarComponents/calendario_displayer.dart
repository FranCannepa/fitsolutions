
import 'package:fitsolutions/components/CalendarComponents/calendario_actividad_card.dart';
import 'package:fitsolutions/components/CalendarComponents/calendario_agregar_actividad_dialog.dart';
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
  late List<Map<String, dynamic>> actividadesFetched;
  String origenActividades = '';

  @override
  void initState() {
    super.initState();
  }

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
    final actividadesProvider = context.read<ActividadProvider>();
    final UserData userProvider = context.read<UserData>();
    userProvider.initializeData();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: actividadesProvider.fetchActividades(fechaSeleccionada),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(
                    child: Column(
                  children: [
                    const NoDataError(message: "No quedan actividades por hoy"),
                    if (!userProvider.esBasico())
                      ElevatedButton(
                        onPressed: () => {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                CalendarioAgregarActividadDialog(
                              propietarioActividadId: origenActividades,
                              onClose: () => Navigator.pop(context),
                            ),
                          )
                        },
                        child: const Text("Nueva Actividad"),
                      ),
                  ],
                ));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                actividadesFetched = snapshot.data!;
                return Center(
                  child: Column(
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DiaActual(),
                          SizedBox(width: 10),
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
                            if (snapshot.data!.isNotEmpty)
                              ElevatedButton(
                                child: const Icon(Icons.arrow_forward_ios),
                                onPressed: () => actividadesSiguientes(),
                              ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final actividad = snapshot.data![index];
                          return SizedBox(
                            child: CartaActividad(actividad: actividad),
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return Text('Error: ${snapshot.error}');
              }
            },
          ),
        ],
      ),
    );
  }
}
