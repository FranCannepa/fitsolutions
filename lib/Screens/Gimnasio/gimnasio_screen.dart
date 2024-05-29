import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class GimnasioScreen extends StatefulWidget {
  const GimnasioScreen({super.key});
  @override
  State<GimnasioScreen> createState() => _GimnasioScreenState();
}

class _GimnasioScreenState extends State<GimnasioScreen> {
  late Map<String, dynamic>? gymData;
  bool showGymForm = false;
  Logger log = Logger();
  Future<Map<String, dynamic>?> getGym() async {
    final userProvider = context.read<UserData>();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('gimnasio')
          .where('propietarioId', isEqualTo: userProvider.userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        final data = docSnapshot.data();
        return data;
      } else {
        return null;
      }
    } catch (e) {
      log.d("Error getting gym data: $e");
      return null;
    }
  }

  void refreshScreen() async {
    gymData = await getGym();
    setState(() {
      showGymForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: getGym(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error fetching gym data: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasData) {
                  final gymData = snapshot.data!;
                  return MyGym(myGym: gymData);
                }
                return !showGymForm
                    ? Column(
                        children: [
                          const ScreenTitle(
                            title: "No tienes ningun gimnasio asociado!",
                          ),
                          ElevatedButton(
                            onPressed: () => setState(() => showGymForm = true),
                            child: const Text("Crear gimnasio"),
                          ),
                        ],
                      )
                    : const SizedBox();
              },
            ),
            if (showGymForm) GimnasioForm(refresh: refreshScreen),
          ],
        ),
      ),
      bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.gym,
      ),
    );
  }
}
