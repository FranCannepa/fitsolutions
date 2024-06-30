import 'dart:developer';

import 'package:fitsolutions/Components/DietasComponents/dietaAdministrador.dart';
import 'package:fitsolutions/Components/DietasComponents/dietaDisplayer.dart';
import 'package:fitsolutions/components/DietasComponents/dieta_form.dart';
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
      body: userData.esBasico()
          ? const DietaDisplayer()
          : const DietaAdministrador(),
      floatingActionButton: userData.esBasico()
          ? null
          : FloatingActionButton(
              heroTag: 'unique1',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DietaForm(
                      origenDieta: userData.origenAdministrador,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
