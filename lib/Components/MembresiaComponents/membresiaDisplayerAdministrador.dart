import 'package:fitsolutions/Components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/Components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/providers/user_data.dart';
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

  Future<String?> _fetchGymId() async {
    return await SharedPrefsHelper().getSubscripcion();
  }

  void _showMyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registro no completado'),
          content: const Text(
              'Complete su registro completando sus datos de Entrenador o Gimnasio'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

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
          : FutureBuilder<String?>(
              future: _fetchGymId(),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for the result
                  return const SizedBox(); // No button while loading
                } else if (snapshot.hasError) {
                  // Handle any errors
                  return FloatingActionButton(
                    heroTag: 'unique5',
                    onPressed: () => _showMyDialog(context),
                    child: const Icon(Icons.add),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return FloatingActionButton(
                    heroTag: 'unique5',
                    onPressed: () => {
                      showDialog(
                        context: context,
                        builder: (context) => MembresiaFormDialog(
                          onClose: () => Navigator.pop(context),
                          origenMembresia: userData.origenAdministrador == ''
                              ? snapshot.data!
                              : userData.origenAdministrador,
                        ),
                      )
                    },
                    child: const Icon(Icons.add),
                  );
                } else {
                  return FloatingActionButton(
                    heroTag: 'unique5',
                    onPressed: () => _showMyDialog(context),
                    child: const Icon(Icons.add),
                  );
                }
              },
            ),
    );
  }
}
