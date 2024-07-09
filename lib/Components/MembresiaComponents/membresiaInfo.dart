import 'package:fitsolutions/components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:flutter/material.dart';

class MembresiaInfo extends StatefulWidget {
  final Membresia membresia;

  const MembresiaInfo({super.key, required this.membresia});

  @override
  State<MembresiaInfo> createState() => _MembresiaInfoState();
}

class _MembresiaInfoState extends State<MembresiaInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenUpperTitle(title: "Mi Membresia"),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 30.0),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.membresia.nombreMembresia,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                widget.membresia.descripcion,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 25),
                      text: '\$',
                    ),
                    TextSpan(
                      text: widget.membresia.costo.toString(),
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => print("Pagar"),
                    child: const Text('Pagar Membresia'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
