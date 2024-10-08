import 'package:flutter/material.dart';


class ParticipanteCard extends StatelessWidget {
  final Map<String, dynamic> clienteData;

  const ParticipanteCard({super.key, required this.clienteData});

  int calculateAge(String fechaNacimiento) {
    final birthday = DateTime.parse(fechaNacimiento);
    final today = DateTime.now();
    return today.difference(birthday).inDays ~/ 365;
  }

  @override
  Widget build(BuildContext context) {
    final age = calculateAge(clienteData['fechaNacimiento']);

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
