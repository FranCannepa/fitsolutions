import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendarioDisplayer.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/modelo/UserData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>?> getUserData() async {
    final docId = await SharedPrefsHelper().getDocId();
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
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CalendarioDisplayer()],
              ),
            ),
            bottomNavigationBar: FooterBottomNavigationBar(
              initialScreen: ScreenType.home,
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("Error fetching user data!"),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
