import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/MembresiaComponents/membresia_form.dart';

//import 'package:fitsolutions/modelo/user_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:provider/provider.dart';

class MembresiaScreen extends StatefulWidget {
  const MembresiaScreen({super.key});

  @override
  State<MembresiaScreen> createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen> {
  late Map<String, dynamic>? membershipData;

  bool showMembresiaForm = false;

  Future<Map<String, dynamic>?> getMembershipInfo() async {
    //final userProvider = context.read<UserData>();
    final prefs = SharedPrefsHelper();
    final gymId = await prefs.getCurrentGymId();
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
      //print("Error getting user: $e");
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
      appBar: AppBar(
        title: const Text('Membresia'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  return Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nombre:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(membershipData['nombre']),
                        const SizedBox(height: 10.0),
                        const Text(
                          'Gimnasio:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(membershipData['gimnasio']),
                        const SizedBox(height: 10.0),
                        const Text(
                          'Costo:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${membershipData['costo']} \$'),
                        const SizedBox(height: 10.0),
                        const Text(
                          'Vencimiento:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy')
                              .format(membershipData['vencimiento']),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
            if (!showMembresiaForm)
              Center(
                child: Column(
                  children: [
                    const Text('No existe membresia para su gimnasio'),
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
      bottomNavigationBar: const FooterBottomNavigationBar(),
    );
  }
}
