import 'package:fitsolutions/Components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/Components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/components/MembresiaComponents/membresia_card.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaDisplayerPropietario extends StatefulWidget {
  final List<Membresia> membresias;
  const MembresiaDisplayerPropietario({super.key, required this.membresias});

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
    final userData = context.read<UserData>();
    return Scaffold(
      body: Column(
        children: [
          const ScreenUpperTitle(title: "Mis Membresias"),
          Expanded(
            child: widget.membresias.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        NoDataError(message: "No cuenta con membresias"),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ...widget.membresias.map(
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
                  ),
          ),
        ],
      ),
      floatingActionButton: userData.esBasico()
          ? null
          : FloatingActionButton(
              heroTag: 'unique5',
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) => MembresiaFormDialog(
                    onClose: () => Navigator.pop(context),
                    origenMembresia: userData.origenAdministrador == ''
                        ? gymId
                        : userData.origenAdministrador,
                  ),
                )
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
