import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:fitsolutions/Components/components.dart';
//import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/Screens/Profile/editar_perfil_screen.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/screens/Inscription/form_inscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Map<String, dynamic> userData;
  Logger log = Logger();
  Future<Map<String, dynamic>?> getUserData() async {
    final userProvider = context.read<UserData>();
    try {
      final docRef = FirebaseFirestore.instance
          .collection('usuario')
          .doc(userProvider.userId);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        userData = snapshot.data() as Map<String, dynamic>;
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      log.d("Error getting user: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 50.0,
                                backgroundImage:
                                    userData['profilePic'] != null &&
                                            userData['profilePic'].isNotEmpty
                                        ? NetworkImage(
                                            userData['profilePic'] as String)
                                        : null,
                                child: userData['profilePic'] == null ||
                                        userData['profilePic'].isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 20.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData['nombreCompleto'] ??
                                        'Usuario de Ejemplo',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                  Text(
                                    userData['tipo'],
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Altura: ${userData['altura'] ?? 'No informada'}',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(
                          'Peso: ${userData['peso'] ?? 'No informado'}',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(
                          'Fecha Nacimiento: ${userData['fechaNacimiento'] ?? 'No informada'}',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        Row(
                          children: [
                            Text(
                              'Edad: ',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              Formatters()
                                  .calculateAge(userData['fechaNacimiento'])
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditarPerfilScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(),
                        child: const Text('Editar Perfil'),
                      ),
                                      ElevatedButton(
                      onPressed: () => {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) =>
                                const FormInscriptionScreen(),
                            transitionsBuilder: (_, Animation<double> animation,
                                __, Widget child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        )
                      },
                      child: const Text('Inscripcion'),
                    ),
                    ],
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Error fetching user data!"),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    ));
  }
}
