import 'package:fitsolutions/Components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaFormDialog.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
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
  List<Membresia> membresiaData = [];
  late String gymId;
  @override
  Widget build(BuildContext context) {
    final membresiaProvider = context.watch<MembresiaProvider>();
    return Scaffold(
      body: FutureBuilder<List<Membresia>>(
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
            if (membershipData.isEmpty) {
              return const Text('Su gimnasio no tiene membresías');
            }
            if (membershipData.isNotEmpty) {
              return Column(
                children: [
                  Container(
                    height: 50.0,
                    margin: const EdgeInsets.only(
                      top: 30.0,
                      left: 30.0,
                      right: 30.0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [ScreenTitle(title: "Mis Membresias")],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...membershipData.map(
                              (membresia) =>
                                  MembershipCard(membresia: membresia),
                            ),
                            const SizedBox(height: 4.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          }
          return Container();
        },
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
