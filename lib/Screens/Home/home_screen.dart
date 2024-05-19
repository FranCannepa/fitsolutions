import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendario_board.dart';
import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/Utilities/NavigatorService.dart';
import 'package:fitsolutions/Utilities/SharedPrefsHelper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>?> getUserData() async {
    final docIdFuture = SharedPrefsHelper().getDocId();
    final docId = await docIdFuture as String;
    try {
      final docRef =
          FirebaseFirestore.instance.collection('usuario').doc(docId);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        NavigationService.instance.pushNamed("/login");
      }
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data as Map<String, dynamic>;
          final userTipo = userData['tipo'];
          final tengoSubscripcion =
              userData['gimnasio'] != null || userData['entrenador'] != null;
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userTipo == "Basico") Text("SOY BASICO"),
                  if (tengoSubscripcion)
                    Text("TENGO SUBSCRIPCION")
                  else
                    Text("NO TENGO GYM O ENTRENADOR ASOCIADO"),
                  if (userTipo == "Propietario" || userTipo == "Particular")
                    Text("SOY PROPIETARIO O PARTICULAR"),
                  if (!tengoSubscripcion) Text("CREAR CALENDARIO"),
                  if (userTipo == null || userTipo.isEmpty)
                    Text("Please update your user type!"),
                ],
              ),
            ),
            bottomNavigationBar: FooterBottomNavigationBar(),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return const Scaffold(
            body: Center(
              child: Text("Error fetching user data!"),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Loading indicator
            ),
          );
        }
      },
    );
  }
}
