import 'package:fitsolutions/Components/MembresiaComponents/membresia_card.dart';
import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:flutter/material.dart';

class SeleccionarMembresia extends StatefulWidget {
  final List<Membresia> membresias;
  final VoidCallback? onBackToMembresiaInfo;
  final Membresia? membresia;
  final bool? showMembresiaInfo;
  const SeleccionarMembresia(
      {super.key,
      required this.membresias,
      this.onBackToMembresiaInfo,
      this.membresia,
      this.showMembresiaInfo});

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
                    if (!widget.showMembresiaInfo! &&
                        widget.membresia != null) ...[
                      ElevatedButton(
                        onPressed: widget.onBackToMembresiaInfo,
                        child: const Text('Volver a Mi Membresia'),
                      ),
                    ],
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
                  NoDataError(
                      message: "Su gimnasio/entrenador no tiene membresias"),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
