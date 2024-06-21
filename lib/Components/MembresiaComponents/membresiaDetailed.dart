import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
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
          ScreenSubTitle(text: membresia.nombreMembresia),
          Text(membresia.descripcion),
          Text(membresia.costo),
          if (!userProvider.esBasico())
            ElevatedButton(
                onPressed: () {
                  print("PRESIONADO");
                },
                child: const Text("Asignar a cliente"))
        ],
      ),
    );
  }
}
