import 'package:fitsolutions/Components/MembresiaComponents/membresia_card.dart';
import 'package:flutter/material.dart';

class SeleccionarMembresia extends StatefulWidget {
  final List<Map<String, dynamic>> membresias;
  const SeleccionarMembresia({super.key, required this.membresias});

  @override
  State<SeleccionarMembresia> createState() => _MembresiaSeleccionadorState();
}

class _MembresiaSeleccionadorState extends State<SeleccionarMembresia> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...widget.membresias.map((membresia) => Center(
                child: MembershipCard(membership: membresia),
              )),
        ],
      )),
    );
  }
}
