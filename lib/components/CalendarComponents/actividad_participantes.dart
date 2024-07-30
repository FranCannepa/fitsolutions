import 'dart:core';
import 'package:fitsolutions/Components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/components/CalendarComponents/participante_card.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActividadParticipantes extends StatelessWidget {
  final String actividadId;
  final VoidCallback onClose;
  const ActividadParticipantes(
      {super.key, required this.actividadId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final gimnasioProvider = context.read<GimnasioProvider>();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Participantes de Actividad',
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>?>(
                future: gimnasioProvider.getParticipantesActividad(actividadId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final clientes = snapshot.data!;
                    if (clientes.isEmpty) {
                      return const Center(
                          child: NoDataError(
                              message: "No tiene participantes"));
                    } else {
                      return Container(
                          margin: const EdgeInsetsDirectional.only(top: 20),
                          child: ListView.builder(
                            itemCount: clientes.length,
                            itemBuilder: (context, index) {
                              final clienteData = clientes[index];
                              return ParticipanteCard(clienteData: clienteData);
                            },
                          ));
                    }
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}