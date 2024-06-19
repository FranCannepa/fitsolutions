import 'package:fitsolutions/Components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_card.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
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
        Container(
          height: 50.0,
          margin: const EdgeInsets.only(
            top: 30.0,
            left: 30.0,
            right: 30.0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [ScreenTitle(title: "Membresias")],
          ),
        ),
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
        ),
      ],
    );
  }
}
