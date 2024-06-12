import 'dart:developer';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaInfo.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaSeleccionador.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaDisplayerBasico extends StatefulWidget {
  final List<Map<String, dynamic>> membresias;
  const MembresiaDisplayerBasico({super.key, required this.membresias});

  @override
  State<MembresiaDisplayerBasico> createState() =>
      _MembresiaDisplayerBasicoState();
}

class _MembresiaDisplayerBasicoState extends State<MembresiaDisplayerBasico> {
  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();

    return Center(
      child: FutureBuilder(
        future: userProvider.getMembresia(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final membresia = snapshot.data!;
            return Visibility(
                visible: snapshot.hasData,
                child: MembresiaInfo(membresiaData: membresia));
          } else if (!snapshot.hasData) {
            return Stack(
              children: [
                Visibility(
                  visible: !snapshot.hasData,
                  child: SeleccionarMembresia(membresias: widget.membresias),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
