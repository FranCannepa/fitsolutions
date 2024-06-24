import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';

class MembresiaDetailed extends StatefulWidget {
  final Membresia membresia;
  final UserData userProvider;
  final MembresiaProvider membresiaProvider;
  final VoidCallback onClose;
  const MembresiaDetailed(
      {super.key,
      required this.membresia,
      required this.membresiaProvider,
      required this.userProvider,
      required this.onClose});

  @override
  State<MembresiaDetailed> createState() => _MembresiaDetailedState();
}

class _MembresiaDetailedState extends State<MembresiaDetailed> {
  @override
  Widget build(BuildContext context) {
    final Membresia membresia = widget.membresia;
    final userProvider = widget.userProvider;
    return Dialog(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(10),
                child: Text(
                  membresia.nombreMembresia,
                  style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Container(
              height: 90,
              width: 250,
              child: membresia.descripcion.isNotEmpty
                  ? Text(
                      membresia.descripcion,
                      style: TextStyle(fontSize: 16),
                    )
                  : const ScreenSubTitle(text: 'No hay descripcion')),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "\$${membresia.costo.toString()}",
                style: const TextStyle(fontSize: 16),
              ),
              if (!userProvider.esBasico())
                SubmitButton(
                    text: "Asingar Cliente",
                    onPressed: () {
                      print("ASIGNAR");
                    })
            ],
          ),
        ],
      ),
    );
  }
}
