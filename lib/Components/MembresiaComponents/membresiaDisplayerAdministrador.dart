import 'package:fitsolutions/Components/MembresiaComponents/membresiaFormDialog.dart';
import 'package:fitsolutions/components/MembresiaComponents/membresia_card.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
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
  late String gymId;
  @override
  Widget build(BuildContext context) {
    final membresiaProvider = context.watch<MembresiaProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: membresiaProvider.getMembresiasOrigen(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final membershipData = snapshot.data!;
                  return Column(
                    children: [
                      if (membershipData.isEmpty)
                        const Column(
                          children: [
                            Text('Su gimnasio no tiene membresías'),
                          ],
                        ),
                      if (membershipData.isNotEmpty)
                        Column(
                          children: [
                            ...membershipData.map((membresia) => Center(
                                  child: MembershipCard(membership: membresia),
                                )),
                            const SizedBox(height: 10),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showDialog(
            context: context,
            builder: (context) => MembresiaFormDialog(
                origenMembresia: context.read<UserData>().origenAdministrador,
                onClose: () => Navigator.pop(context)),
          )
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
