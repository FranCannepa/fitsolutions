import 'dart:developer';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AsignarDietaDialog extends StatefulWidget {
  final Dieta dieta;
  final VoidCallback onClose;
  const AsignarDietaDialog(
      {super.key, required this.dieta, required this.onClose});

  @override
  State<AsignarDietaDialog> createState() => _AsignarDietaDialogState();
}

class _AsignarDietaDialogState extends State<AsignarDietaDialog> {
  late String? clienteSeleccionado;
  void updateClienteSeleccionado(String value) {
    clienteSeleccionado = value;
  }

  void _showSuccessModal(String mensaje, ResultType resultado) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(text: mensaje, resultType: resultado);
      },
    ).then((_) {
      if (resultado == ResultType.success) {
        widget.onClose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dieta = widget.dieta;
    final GimnasioProvider gimnasioProvider = context.watch<GimnasioProvider>();
    final UserData userProvider = context.read<UserData>();
    final DietaProvider dietaProvider = context.read<DietaProvider>();

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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Asignar Dieta',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: gimnasioProvider
                  .getClientesGym(userProvider.origenAdministrador),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final users = snapshot.data!;
                  List<DropdownMenuItem<String>> dropdownItems =
                      users.map((user) {
                    final userId = user['usuarioId'] as String;
                    final userName = user['nombreCompleto'] as String;
                    return DropdownMenuItem(
                      value: userId,
                      child: Text(userName),
                    );
                  }).toList();
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: null,
                        items: dropdownItems,
                        onChanged: (value) {
                          setState(() {
                            updateClienteSeleccionado(value!);
                          });
                        },
                        hint: const Text('Select User'),
                      ),
                      const SizedBox(height: 20),
                      SubmitButton(
                          text: "Asignar",
                          onPressed: () async {
                            if (clienteSeleccionado != null) {
                              final result = await dietaProvider.asignarDieta(
                                  dieta.id, clienteSeleccionado as String);
                              if (result) {
                               _showSuccessModal("Dieta asignada exitosamente", ResultType.success);
                              } else {
                                const ResultDialog(
                                    text: "Error al asignar dieta",
                                    resultType: ResultType.error);
                                widget.onClose;
                              }
                            } else {
                              return const ResultDialog(
                                  text: "Cliente no seleccionado",
                                  resultType: ResultType.warning);
                            }
                          })
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Center(child: CircularProgressIndicator());
              },
            )
          ]),
        ));
  }
}
