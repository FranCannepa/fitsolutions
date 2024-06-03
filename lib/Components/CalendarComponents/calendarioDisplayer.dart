import 'package:fitsolutions/Components/CommonComponents/noDataError.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/modelo/UserData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarioDisplayer extends StatefulWidget {
  const CalendarioDisplayer({super.key});

  @override
  State<CalendarioDisplayer> createState() => _CalendarioDisplayerState();
}

class _CalendarioDisplayerState extends State<CalendarioDisplayer> {
  DateTime fechaSeleccionada = DateTime.now();

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future:
                context.read<UserData>().fetchActividades(fechaSeleccionada),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.done) {
                final actividades = snapshot.data!;
                return Center(
                  child: Column(
                    children: [
                      if (actividades.isEmpty)
                        const NoDataError(
                          message: "No quedan actividades por hoy",
                        )
                      else
                        const ScreenTitle(title: "Actividades"),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: actividades.length,
                        itemBuilder: (context, index) {
                          final actividad = actividades[index];
                          return SizedBox(
                            child: CartaActividad(actividad: actividad),
                          );
                        },
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
                            if (actividades.isNotEmpty)
                              ElevatedButton(
                                child: const Icon(Icons.arrow_forward_ios),
                                onPressed: () => actividadesSiguientes(),
                              ),
                          ],
                        ),
                      )
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
