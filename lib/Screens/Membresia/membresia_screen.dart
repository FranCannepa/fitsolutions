import 'dart:developer';

import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Membresia {
  final String nombre;
  final double precio;

  Membresia({required this.nombre, required this.precio});
}

class MembresiaScreen extends StatefulWidget {
  final UserData provider;
  const MembresiaScreen({super.key, required this.provider});

  @override
  State<MembresiaScreen> createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen> {
  @override
  Widget build(BuildContext context) {
    context.read<UserData>().initializeData();
    final MembresiaProvider provider = context.read<MembresiaProvider>();
    final UserData userData = context.read<UserData>();
    return Scaffold(
      body: FutureBuilder(
        future: provider.getMembresiasOrigen(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final membresias = snapshot.data!;
            return userData.esBasico()
                ? MembresiaDisplayerBasico(membresias: membresias)
                : const MembresiaDisplayerPropietario();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al obtener las membresias'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
