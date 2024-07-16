import 'dart:core';
import 'package:fitsolutions/Components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/Components/GimnasioComponents/gimnasio_cliente_card.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GimnasioClientes extends StatelessWidget {
  final String gimnasioId;
  final VoidCallback onClose;
  const GimnasioClientes(
      {super.key, required this.gimnasioId, required this.onClose});

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
                    'Mis Clientes',
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
                future: gimnasioProvider.getClientesGym(gimnasioId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final clientes = snapshot.data!;
                    if (clientes.isEmpty) {
                      return const Center(
                          child: NoDataError(
                              message: "No tiene clientes asociados"));
                    } else {
                      return Container(
                          margin: const EdgeInsetsDirectional.only(top: 20),
                          child: ListView.builder(
                            itemCount: clientes.length,
                            itemBuilder: (context, index) {
                              final clienteData = clientes[index];
                              return ClienteCard(clienteData: clienteData);
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
