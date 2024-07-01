import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_detailed_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/MembresiaComponents/membresia_edit_dialog.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_payment_service.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';

class MembershipCard extends StatelessWidget {
  final Membresia membresia;

  const MembershipCard({super.key, required this.membresia});

  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();
    final MembresiaProvider membresiaProvider =
        context.read<MembresiaProvider>();
    final PaymentService paymentService = PaymentService();
    final prefs = SharedPrefsHelper();
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 4.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => MembresiaDetailed(
              membresia: membresia,
              membresiaProvider: membresiaProvider,
              userProvider: userProvider,
              onClose: () => Navigator.pop(context),
            ),
          );
        },
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    membresia.nombreMembresia,
                    style: TextStyle(
                      fontSize: const TextStyle(fontSize: 35.0).fontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!userProvider.esBasico()) const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: Colors.black),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => MembresiaEdit(
                                          membresia: membresia,
                                          onClose: () {
                                            Navigator.pop(context);
                                          },
                                        ));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Confirmar eliminación',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    content: Text(
                                      '¿Está seguro de que desea eliminar la actividad "${membresia.nombreMembresia}"?',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final success =
                                              await membresiaProvider
                                                  .eliminarMembresia(
                                                      membresia.id);
                                          if (success) {
                                            const ResultDialog(
                                                text:
                                                    "Membresia actualizada exitosamente",
                                                resultType: ResultType.success);
                                          } else {
                                            const ResultDialog(
                                                text:
                                                    "Error al actualizar membresia",
                                                resultType: ResultType.error);
                                          }
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text(
                                          'Eliminar',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              color: Colors.black,
              width: 130.0,
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "\$${membresia.costo.toString()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      const Text(
                        "Mensualmente",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
