import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/Screens/Profile/editar_perfil_screen.dart';
import 'package:fitsolutions/modelo/models.dart';
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: getUserData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                userData = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: userData['profilePic'] != null &&
                              userData['profilePic'].isNotEmpty
                          ? NetworkImage(userData['profilePic'] as String)
                          : null,
                      child: userData['profilePic'] == null ||
                              userData['profilePic'].isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      'Nombre Completo',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    Text(userData['nombreCompleto'] ?? 'Usuario de Ejemplo'),
                    Text(userData['tipo']),
                    const SizedBox(height: 16.0),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditarPerfilScreen()),
                        );
                      },
                      child: const Text('Editar Perfil'),
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
      ),
      bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.perfil,
      ),
    );
  }
}
