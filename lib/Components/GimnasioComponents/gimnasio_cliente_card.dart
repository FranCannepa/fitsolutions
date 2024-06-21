import 'package:flutter/material.dart';

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

    return Card(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (clienteData['profilePic'] != null)
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(clienteData['profilePic']),
                            radius: 40.0,
                          ),
                        const SizedBox(width: 16.0),
                      ]),
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
                    ],
                  ),
                )
              ],
            )));
  }
}
