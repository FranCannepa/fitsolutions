import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActividadDialog extends StatelessWidget {
  final Actividad actividad;
  final VoidCallback onClose;

  const ActividadDialog(
      {super.key, required this.actividad, required this.onClose});

  @override
  Widget build(BuildContext context) {
    void showSuccessModal(String mensaje, ResultType resultado) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResultDialog(text: mensaje, resultType: resultado);
        },
      ).then((_) {
        if (resultado == ResultType.success) {
          onClose();
        }
      });
    }

    final ActividadProvider actividadProvider =
        context.read<ActividadProvider>();
    final UserData userProvider = context.read<UserData>();
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      child: Text(
                        actividad.nombre,
                        style: const TextStyle(
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
                FutureBuilder<bool>(
                  future: actividadProvider.estaInscripto(
                      userProvider.userId, actividad.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final isInscrito = snapshot.data!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: SubmitButton(
                              text:
                                  isInscrito ? "Darse de baja" : "Inscribirse",
                              onPressed: () async {
                                if (isInscrito) {
                                  final result = await actividadProvider
                                      .desinscribirseActividad(context,
                                          userProvider.userId, actividad.id);
                                  if (result) {
                                    showSuccessModal(
                                        "Dado de baja exitosamente",
                                        ResultType.success);
                                  } else {
                                    showSuccessModal("Error al darse de baja",
                                        ResultType.error);
                                  }
                                } else {
                                  final result =
                                      await actividadProvider.anotarseActividad(context,
                                          userProvider.userId, actividad.id);

                                  if (result) {
                                    showSuccessModal("Inscripcion exitosa",
                                        ResultType.success);
                                  } else {
                                    showSuccessModal("Error al inscribirse",
                                        ResultType.error);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    return const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ));
  }
}
