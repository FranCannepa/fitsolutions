import 'package:fitsolutions/Components/DietasComponents/dietaAdministrador.dart';
import 'package:fitsolutions/Components/DietasComponents/dietaDisplayer.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/DietasComponents/dieta_form.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietasScreen extends StatefulWidget {
  const DietasScreen({super.key});

  @override
  State<DietasScreen> createState() => _DietasScreenState();
}

String? dietaOrigen;


class _DietasScreenState extends State<DietasScreen> {
  
  @override
  void initState() {
    super.initState();
    getDietaOrigen();
  }

  void getDietaOrigen() async {
    final fetchDietaOrigen = await SharedPrefsHelper().getSubscripcion();
    setState((){
      dietaOrigen = fetchDietaOrigen;
    });
  }

  void _showMyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Registro no completado'),
            content: const Text('Complete su registro completando sus datos de Entrenador o Gimnasio'),
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
    return Scaffold(
      body: userData.esBasico()
          ? const DietaDisplayer()
          : const DietaAdministrador(),
      floatingActionButton: userData.esBasico()
          ? null
          : dietaOrigen != null && dietaOrigen != ''  ?
               FloatingActionButton(
                  heroTag: 'unique1',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DietaForm(
                          origenDieta: userData.origenAdministrador == ''
                              ? dietaOrigen!
                              : userData.origenAdministrador,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : FloatingActionButton(
                  heroTag: 'unique1',
                  onPressed: () => _showMyDialog(context),
                  child: const Icon(Icons.add),
                ),
    );
  }
}
