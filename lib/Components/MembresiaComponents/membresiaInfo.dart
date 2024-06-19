import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_payment_service.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
import 'package:flutter/material.dart';

class MembresiaInfo extends StatelessWidget {
  final Membresia membresia;

  const MembresiaInfo({super.key, required this.membresia});

  @override
  Widget build(BuildContext context) {
    final PaymentService _paymentService = PaymentService();
    // final nombreMembresia = membresiaData['nombreMembresia'] as String;
    // final descripcion = membresiaData['descripcion'] as String;
    // final costo = membresiaData['costo'];

    void handlePayment(double costo) {
      //_paymentService.createPayment(context, costo, 'cliente1@correo.com');
    }

    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      constraints: const BoxConstraints.expand(width: double.infinity),
      margin: const EdgeInsets.symmetric(vertical: 150, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ScreenSubTitle(text: "Mi membresia"),
          Text(
            membresia.nombreMembresia,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(membresia.descripcion),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Costo: '),
              Text(membresia.costo.toString()),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () => {print("Pagar")},
              child: const Text('Pagar Membresia'))
        ],
      ),
    );
  }
}
