import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/RegisterComponents/GimnasioForm.dart';
import 'package:fitsolutions/Utilities/NavigatorService.dart';
import 'package:fitsolutions/Utilities/SharedPrefsHelper.dart';
import 'package:flutter/material.dart';

class RegistroGymScreen extends StatefulWidget {
  const RegistroGymScreen({super.key});

  @override
  _RegistroGymScreenState createState() => _RegistroGymScreenState();
}

class _RegistroGymScreenState extends State<RegistroGymScreen> {
  late Map<String, dynamic> gymData = {};
  Future<void> registerGym(Map<String, dynamic> gymData) async {
    final prefs = SharedPrefsHelper();
    try {
      final docRef =
          await FirebaseFirestore.instance.collection('gimnasio').add(gymData);
      prefs.setLoggedIn(true);
      prefs.setDocId(docRef.id);
      NavigationService.instance.pushNamed("/home");
    } on FirebaseException catch (e) {
      print(e.code);
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GimnasioForm(),
    );
  }
}
