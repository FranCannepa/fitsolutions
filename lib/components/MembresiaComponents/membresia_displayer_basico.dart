import 'dart:developer';

import 'package:fitsolutions/Components/MembresiaComponents/membresiaInfo.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaSeleccionador.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_payment_service.dart';

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
    final PaymentService paymentService = PaymentService();

    paymentService.verifyPayment(context);

    return Center(
      child: FutureBuilder<Membresia?>(
        future: userProvider.getMembresia(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final membresia = snapshot.data!;
            return Visibility(
                visible: snapshot.hasData,
                child: MembresiaInfo(membresia: membresia));
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
