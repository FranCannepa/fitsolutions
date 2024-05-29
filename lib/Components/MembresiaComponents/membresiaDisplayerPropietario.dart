import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaCard.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/modelo/UserData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaDisplayerPropietario extends StatefulWidget {
  const MembresiaDisplayerPropietario({super.key});

  @override
  State<MembresiaDisplayerPropietario> createState() =>
      _MembresiaDisplayerPropietarioState();
}

class _MembresiaDisplayerPropietarioState
    extends State<MembresiaDisplayerPropietario> {
  List<Map<String, dynamic>> membresiaData = [];
  bool showMembresiaForm = false;
  late String gymId;

  Future<String?> getGym() async {
    final userProvider = context.read<UserData>();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('gimnasio')
          .where('propietarioId', isEqualTo: userProvider.userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        userProvider.updateCurrentGym(docSnapshot.id);
        return docSnapshot.id;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMembershipData() async {
    final gimnasioId = await getGym();
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('membresia')
          .where('gimnasioId', isEqualTo: gimnasioId);
      final querySnapshot = await collectionRef.get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
            .map((docSnapshot) => docSnapshot.data())
            .toList();
      } else {
        print('No memberships found for this gym');
        return [];
      }
    } catch (e) {
      print("Error getting memberships: $e");
      return [];
    }
  }

  void refreshScreen() async {
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
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchMembershipData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final membershipData = snapshot.data!;
                if (showMembresiaForm) {
                  return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MembresiaForm(refresh: refreshScreen),
                        TextButton(
                          onPressed: () => {showMembresiaForm = false},
                          child: const Text('Cancelar'),
                        )
                      ]);
                } else {
                  return Column(
                    children: [
                      if (membershipData.isEmpty)
                        Column(
                          children: [
                            const Text('Su gimnasio no tiene membresías'),
                            ElevatedButton(
                              onPressed: () =>
                                  setState(() => showMembresiaForm = true),
                              child: const Text("Crear Membresia"),
                            ),
                          ],
                        ),
                      if (membershipData.isNotEmpty)
                        Column(
                          // Wrap membership cards and button in another Column
                          children: [
                            ...membershipData // Display membership cards
                                .map((membresia) => Center(
                                      child:
                                          MembershipCard(membership: membresia),
                                    ))
                                .toList(),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () =>
                                  setState(() => showMembresiaForm = true),
                              child: const Text("Crear Membresia"),
                            ),
                          ],
                        ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
