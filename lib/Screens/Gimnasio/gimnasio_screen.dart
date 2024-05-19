import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:fitsolutions/Components/CommonComponents/screen_title.dart';
import 'package:fitsolutions/Components/RegisterComponents/GimnasioForm.dart';
import 'package:fitsolutions/Modelo/UserData.dart';
import 'package:fitsolutions/Utilities/NavigatorService.dart';
import 'package:fitsolutions/Utilities/SharedPrefsHelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GimnasioScreen extends StatefulWidget {
  const GimnasioScreen({Key? key}) : super(key: key);

  @override
  _GimnasioScreenState createState() => _GimnasioScreenState();
}

class _GimnasioScreenState extends State<GimnasioScreen> {
  late Map<String, dynamic> gymData;
  bool showGymForm = false;
  Future<Map<String, dynamic>?> getGym() async {
    final docIdFuture = SharedPrefsHelper().getDocId();
    final docId = await docIdFuture as String;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('gimnasio')
          .where('propietarioId', isEqualTo: docId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        final data = docSnapshot.data() as Map<String, dynamic>;
      } else {
        print("No gym data found for owner: $docId");
        return null;
      }
    } catch (e) {
      print("Error getting gym data: $e");
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const FooterBottomNavigationBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ScreenTitle(title: "Ingresa tu gimnasio"),
              FutureBuilder(
                  future: getGym(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (snapshot.hasData) {
                      showGymForm = true;
                      final gymData = snapshot.data!;
                      return Text("GYM DATA");
                    } else {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [],
                      );
                    }
                  }),
              Visibility(
                visible: !showGymForm,
                child: ElevatedButton(
                  onPressed: () {
                    showGymForm = true;
                  },
                  child: const Text("Crear gimnasio"),
                ),
              ),
              Visibility(visible: showGymForm, child: const GimnasioForm()),
            ],
          ),
        ));
  }
}
