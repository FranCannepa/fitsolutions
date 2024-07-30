import 'package:fitsolutions/modelo/membresia_asignada.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class ClienteCard extends StatelessWidget {
  final Map<String, dynamic> clienteData;

  const ClienteCard({super.key, required this.clienteData});

  int calculateAge(String fechaNacimiento) {
    final birthday = DateTime.parse(fechaNacimiento);
    final today = DateTime.now();
    return today.difference(birthday).inDays ~/ 365;
  }

  @override
  Widget build(BuildContext context) {
    final age = calculateAge(clienteData['fechaNacimiento']);
    final usuarioId = clienteData['usuarioId'];

    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 4.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: clienteData['profilePic'] != null &&
                            clienteData['profilePic'].isNotEmpty
                        ? NetworkImage(clienteData['profilePic'] as String)
                        : null,
                    radius: 40.0,
                  ),
                  const SizedBox(width: 16.0),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8.0),
                      Text(
                        clienteData['nombreCompleto'],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.cake),
                      const SizedBox(width: 8.0),
                      Text('$age años'),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.height),
                      const SizedBox(width: 8.0),
                      Text('${clienteData['altura']} cm'),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.scale),
                      const SizedBox(width: 8.0),
                      Text('${clienteData['peso']} kg'),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          '${clienteData['email']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  FutureBuilder<MembresiaAsignada?>(
                    future: context.watch<MembresiaProvider>().obtenerInformacionMembresiaUser(usuarioId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            color: Colors.black,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              'Usuario sin membresia disponible',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        );
                      } else {
                        final membresiaAsignada = snapshot.data!;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            color: Colors.black,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Membresía',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Estado: ${membresiaAsignada.estado}',
                                  style:  TextStyle(
                                    color: membresiaAsignada.estado == 'activa' ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  'Cupos Restantes: ${membresiaAsignada.cuposRestantes}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Fecha de Compra: ${DateFormat().format(membresiaAsignada.fechaCompra)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Fecha de Expiración: ${DateFormat().format(membresiaAsignada.fechaExpiracion)}',
                                  style:  TextStyle(
                                    color: membresiaAsignada.fechaExpiracion.isBefore(DateTime.now()) ? Colors.red : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async{
                                      membresiaAsignada.estado == 'activa' ? await context.read<MembresiaProvider>().cambiarEstadoMembresia(false, membresiaAsignada.id) : 
                                      await context.read<MembresiaProvider>().cambiarEstadoMembresia(true, membresiaAsignada.id);
                                    },
                                    child: Text(
                                      membresiaAsignada.estado == 'activa' ? 'Deshabilitar' : 'Habilitar',
                                    ),
                                  )
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
