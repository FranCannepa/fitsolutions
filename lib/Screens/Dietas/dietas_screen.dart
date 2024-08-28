import 'package:fitsolutions/Components/DietasComponents/dieta_administrador.dart';
import 'package:fitsolutions/Components/DietasComponents/dieta_displayer.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/DietasComponents/dieta_form.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietasScreen extends StatefulWidget {
  const DietasScreen({super.key});

  @override
  State<DietasScreen> createState() => _DietasScreenState();
}

class _DietasScreenState extends State<DietasScreen> {
  Future<String?> _getDietaOrigen() async {
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
    final UserData userData = context.read<UserData>();
    context.watch<GimnasioProvider>();
    return Scaffold(
      body: userData.esBasico()
          ? const DietaDisplayer()
          : const DietaAdministrador(),
      floatingActionButton: userData.esBasico()
          ? null
          : FutureBuilder<String?>(
              future: _getDietaOrigen(),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return FloatingActionButton(
                    heroTag: 'unique1',
                    onPressed: () => _showMyDialog(context),
                    child: const Icon(Icons.error),
                  );
                } else {
                  final dietaOrigen = snapshot.data;
                  return FloatingActionButton(
                    heroTag: 'unique1',
                    onPressed: () {
                      if (dietaOrigen != null && dietaOrigen.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DietaForm(
                              origenDieta: userData.origenAdministrador == ''
                                  ? dietaOrigen
                                  : userData.origenAdministrador,
                            ),
                          ),
                        );
                      } else {
                        _showMyDialog(context);
                      }
                    },
                    child: const Icon(Icons.add),
                  );
                }
              },
            ),
    );
  }
}

