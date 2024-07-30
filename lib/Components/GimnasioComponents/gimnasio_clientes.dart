import 'dart:core';
import 'package:fitsolutions/Components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/Components/GimnasioComponents/gimnasio_cliente_card.dart';
import 'package:fitsolutions/modelo/membresia_asignada.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GimnasioClientes extends StatefulWidget {
  final String gimnasioId;
  final VoidCallback onClose;
  const GimnasioClientes({super.key, required this.gimnasioId, required this.onClose});

  @override
  State<GimnasioClientes> createState() => _GimnasioClientesState();
}

class _GimnasioClientesState extends State<GimnasioClientes> {
  List<Map<String, dynamic>>? clientesConMembresia;

  @override
  void initState() {
    super.initState();
    fetchClientesConMembresia();
  }

  Future<void> fetchClientesConMembresia() async {
    final gimnasioProvider = context.read<GimnasioProvider>();
    final membresiaProvider = context.read<MembresiaProvider>();

    List<Map<String, dynamic>> clientes = await gimnasioProvider.getClientesGym(widget.gimnasioId);
    List<Map<String, dynamic>> clientesConMembresia = [];

    for (var cliente in clientes) {
      final usuarioId = cliente['usuarioId'];
      final membresia = await membresiaProvider.obtenerInformacionMembresiaUser(usuarioId);
      if (membresia != null) {
        cliente['membresia'] = membresia;
      }
      clientesConMembresia.add(cliente);
    }

    clientesConMembresia.sort((a, b) {
      final membresiaA = a['membresia'] as MembresiaAsignada?;
      final membresiaB = b['membresia'] as MembresiaAsignada?;
      if (membresiaA == null && membresiaB == null) return 0;
      if (membresiaA == null) return 1;
      if (membresiaB == null) return -1;
      return membresiaA.fechaExpiracion.compareTo(membresiaB.fechaExpiracion);
    });

    setState(() {
      this.clientesConMembresia = clientesConMembresia;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MembresiaProvider>();
    context.watch<GimnasioProvider>();
    
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
                  onPressed: widget.onClose,
                ),
              ],
            ),
            Expanded(
              child: clientesConMembresia == null
                  ? const Center(child: CircularProgressIndicator())
                  : clientesConMembresia!.isEmpty
                      ? const Center(child: NoDataError(message: "No tiene clientes asociados"))
                      : Container(
                          margin: const EdgeInsetsDirectional.only(top: 20),
                          child: ListView.builder(
                            itemCount: clientesConMembresia!.length,
                            itemBuilder: (context, index) {
                              final clienteData = clientesConMembresia![index];
                              return ClienteCard(clienteData: clienteData);
                            },
                          )),
            ),
          ],
        ),
      ),
    );
  }
}
