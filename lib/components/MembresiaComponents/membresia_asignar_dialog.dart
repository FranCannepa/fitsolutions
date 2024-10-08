import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaAsignarDialog extends StatefulWidget {
  final Membresia membresia;
  final VoidCallback onClose;
  const MembresiaAsignarDialog(
      {super.key, required this.membresia, required this.onClose});

  @override
  State<MembresiaAsignarDialog> createState() => _MembresiaAsignarDialogState();
}

class _MembresiaAsignarDialogState extends State<MembresiaAsignarDialog> {
  String? clienteSeleccionado;
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
    final membresia = widget.membresia;
    final GimnasioProvider gimnasioProvider = context.watch<GimnasioProvider>();
    final UserData userProvider = context.read<UserData>();
    final MembresiaProvider membershipProivder =
        context.read<MembresiaProvider>();

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
                    'Asignar Membresia',
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
                    final userName = user['email'] as String;
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
                        hint: const Text('Seleccionar Usuario'),
                      ),
                      const SizedBox(height: 20),
                      SubmitButton(
                          text: "Asignar",
                          onPressed: () async {
                            if (clienteSeleccionado != null) {
                              try {
                                final result =
                                    await membershipProivder.asignarMembresia(
                                        membresia.id,
                                        clienteSeleccionado as String);
                                if (result) {
                                  _showSuccessModal(
                                      "Membresia asignada exitosamente",
                                      ResultType.success);
                                } else {
                                  _showSuccessModal(
                                      "Este usuario ya tiene una membresia activa",
                                      ResultType.error);
                                  widget.onClose;
                                }
                              } catch (e) {
                                _showSuccessModal(
                                    e.toString(), ResultType.error);
                              }
                            } else {
                              _showSuccessModal("Cliente no seleccionado",
                                  ResultType.warning);
                            }
                          })
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              },
            )
          ]),
        ));
  }
}
