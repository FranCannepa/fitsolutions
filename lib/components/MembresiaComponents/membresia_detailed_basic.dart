import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/modelo/membresia_asignada.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';

class MembresiaDialogBasic extends StatelessWidget {
  final String usuarioId;

  const MembresiaDialogBasic({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    final membershipProvider = context.watch<MembresiaProvider>();
    return FutureBuilder<MembresiaAsignada?>(
      future: membershipProvider.obtenerInformacionMembresiaUser(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
              child: NoDataError(
                  message: 'No hay informacion de membresia disponible'));
        } else {
          final membresiaAsignada = snapshot.data!;
          final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
          return AlertDialog(
            title: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Informacion de Membresia',
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow(
                    'Membresia:', membresiaAsignada.membresia.nombreMembresia),
                _buildInfoRow(
                    'Precio:', '${membresiaAsignada.membresia.costo} UYU'),
                _buildInfoRow('Cupos Restantes:',
                    membresiaAsignada.cuposRestantes.toString()),
                _buildInfoRow('Estado:', membresiaAsignada.estado),
                _buildInfoRow(
                    'Fecha de Compra:',
                    dateFormat
                        .format(membresiaAsignada.fechaCompra)
                        .toString()),
                _buildInfoRow(
                    'Fecha de Expiración:',
                    dateFormat
                        .format(membresiaAsignada.fechaExpiracion)
                        .toString()),
                // Add more fields as needed
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
