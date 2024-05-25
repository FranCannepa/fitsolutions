import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:fitsolutions/Components/CommonComponents/screen_title.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_form.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaInfo.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/Modelo/UserData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaScreen extends StatefulWidget {
  const MembresiaScreen({super.key});

  @override
  State<MembresiaScreen> createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen> {
  late Map<String, dynamic>? membershipData;
  bool showMembresiaForm = false;

  Future<Map<String, dynamic>?> getMembershipInfo() async {
    final userProvider = context.read<UserData>();
    final gymId = userProvider.gimnasioId;
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('membresia')
          .where('gimnasioId', isEqualTo: gymId);
      final querySnapshot = await collectionRef.get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        final data = docSnapshot.data();
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void refreshScreen() async {
    membershipData = await getMembershipInfo();
    setState(() {
      showMembresiaForm = false;
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
            const ScreenTitle(title: "Membresia"),
            FutureBuilder(
              future: getMembershipInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error fetching gym data: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasData) {
                  final membershipData = snapshot.data!;
                  final userProvider = context.read<UserData>();
                  if (userProvider.esPropietario()) {
                    return MembresiaInfo(membershipData: membershipData);
                  } else if (userProvider.esBasico()) {
                    return const Text("SOY BASICO");
                  }
                }
                return Container();
              },
            ),
            if (!showMembresiaForm)
              Center(
                child: Column(
                  children: [
                    const Text(
                      'No existe membresia para su gimnasio',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showMembresiaForm = true;
                        });
                      },
                      child: const Text("Crear Membresia"),
                    ),
                  ],
                ),
              ),
            if (showMembresiaForm) MembresiaForm(refresh: refreshScreen),
          ],
        ),
      ),
      bottomNavigationBar:
          const FooterBottomNavigationBar(initialScreen: ScreenType.membresia),
    );
  }
}
