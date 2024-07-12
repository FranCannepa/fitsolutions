import 'package:fitsolutions/Components/MembresiaComponents/membresia_card.dart';
import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:flutter/material.dart';

class SeleccionarMembresia extends StatefulWidget {
  final List<Membresia> membresias;
  const SeleccionarMembresia({super.key, required this.membresias});

  @override
  State<SeleccionarMembresia> createState() => _MembresiaSeleccionadorState();
}

class _MembresiaSeleccionadorState extends State<SeleccionarMembresia> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenUpperTitle(
          title: "Membresias",
        ),
        if (widget.membresias.isNotEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...widget.membresias.map(
                      (membresia) => MembershipCard(membresia: membresia),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NoDataError(message: "Su gimnasio no tiene membresias"),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
