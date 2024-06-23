import 'package:fitsolutions/Components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/Components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/components/MembresiaComponents/membresia_agregar_dialog.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Membresia>>(
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
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 300.0),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            NoDataError(
                                message: "Su gimnasio no tiene membresias"),
                          ],
                        ),
                      ),
                    );
                  }
                  if (membershipData.isNotEmpty) {
                    return Column(
                      children: [
                        const ScreenUpperTitle(
                          title: "Mis Membresias",
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
          )
        ],
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
