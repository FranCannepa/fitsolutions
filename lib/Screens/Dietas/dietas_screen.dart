import 'package:fitsolutions/Components/DietasComponents/dietaAdministrador.dart';
import 'package:fitsolutions/Components/DietasComponents/dietaAgregarDialog.dart';
import 'package:fitsolutions/Components/DietasComponents/dietaDisplayer.dart';
//import 'package:fitsolutions/Components/components.dart';
//import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietasScreen extends StatefulWidget {
  const DietasScreen({super.key});

  @override
  State<DietasScreen> createState() => _DietasScreenState();
}

class _DietasScreenState extends State<DietasScreen> {
  @override
  Widget build(BuildContext context) {
    context.read<UserData>().initializeData();
    final UserData userData = context.read<UserData>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          userData.esBasico()
              ? const DietaDisplayer()
              : const DietaAdministrador(),
        ],
      ),
      /*bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.dietas,
      ),*/
      floatingActionButton: userData.esBasico()
          ? null
          : FloatingActionButton(
              heroTag: 'unique1',
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) => DietaAgregarDialog(
                    origenDieta: userData.origenAdministrador,
                    onClose: () => Navigator.pop(context),
                  ),
                )
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
