import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:flutter/material.dart';

class MembresiaInfo extends StatelessWidget {
  final Map<String, dynamic> membresiaData;

  const MembresiaInfo({super.key, required this.membresiaData});

  @override
  Widget build(BuildContext context) {
    final nombreMembresia = membresiaData['nombreMembresia'] as String;
    final descripcion = membresiaData['descripcion'] as String;
    final costo = membresiaData['costo'];
    //final Map<String,dynamic> origeMembresia = membresiaData['origenMembresia'];

    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      constraints: const BoxConstraints.expand(width: double.infinity),
      margin: const EdgeInsets.symmetric(vertical: 150, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ScreenSubTitle(text: "Mi membresia"),
          Text(
            nombreMembresia,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(descripcion),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Costo: '),
              Text(costo.toString()),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
