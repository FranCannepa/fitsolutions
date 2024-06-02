import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
//import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../modelo/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Logger logger = Logger();
  Future<Map<String, dynamic>?> getUserData() async {
    //final userProvider = context.read<UserData>();
    final prefs = SharedPrefsHelper();
    try {
      final docRef = FirebaseFirestore.instance
          .collection('usuario')
          .doc(await prefs.getDocId());
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        NavigationService.instance.pushNamed("/login");
      }
    } catch (e) {
      logger.d("Error getting user: $e");
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Logger log = Logger();
    final userProvider = context.read<UserData>();
    return FutureBuilder(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data as Map<String, dynamic>;
          final userTipo = userData['tipo'];
          final anotadoGym = userData['gimnasioId'] != null;
          //final tengoGym =
          return Scaffold(
            appBar: AppBar(
              title: const Text('BIENVENIDO'),
              actions: [
                IconButton(
                  onPressed: () async {
                    UserProvider userProvider = context.read<UserProvider>();
                    await userProvider.signOut();
                    if (context.mounted) {
                      NavigationService.instance.pushNamed("/login");
                    }
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userProvider.esBasico() && !anotadoGym)
                    const Text("SOY BASICO y no tengo sub"),
                  if (anotadoGym && (userProvider.esPropietario()))
                    const Text("NO TENGO GYM O ENTRENADOR ASOCIADO"),
                  if (userTipo == "Propietario")
                    if (!anotadoGym) const Text("CREAR CALENDARIO"),
                  if (userTipo == null || userTipo.isEmpty)
                    const Text("Please update your user type!"),
                ],
              ),
            ),
            bottomNavigationBar: const FooterBottomNavigationBar(
              initialScreen: ScreenType.home,
            ),
          );
        } else if (snapshot.hasError) {
          log.d(snapshot.error);
          return const Scaffold(
            body: Center(
              child: Text("Error fetching user data!"),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Loading indicator
            ),
          );
        }
      },
    );
  }
}
