import 'dart:developer';

import 'package:fitsolutions/Components/MembresiaComponents/membresiaInfo.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaSeleccionador.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaDisplayerBasico extends StatefulWidget {
  final List<Membresia> membresias;
  const MembresiaDisplayerBasico({super.key, required this.membresias});

  @override
  State<MembresiaDisplayerBasico> createState() =>
      _MembresiaDisplayerBasicoState();
}

class _MembresiaDisplayerBasicoState extends State<MembresiaDisplayerBasico> {
  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();
    userProvider.initializeData();
    return Center(
      child: FutureBuilder<Membresia?>(
        future: userProvider.getMembresia(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final membresia = snapshot.data;
            return membresia != null
                ? MembresiaInfo(membresia: membresia)
                : SeleccionarMembresia(membresias: widget.membresias);
          }
        },
      ),
    );
  }
}
