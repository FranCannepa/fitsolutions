import 'dart:developer';

import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_payment_service.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaInfo extends StatelessWidget {
  final Membresia membresia;

  const MembresiaInfo({super.key, required this.membresia});

  @override
  Widget build(BuildContext context) {
    final PaymentService _paymentService = PaymentService();

    void handlePayment(double costo) {
      //_paymentService.createPayment(context, costo, 'cliente1@correo.com');
    }

    final membersiaProvider = context.read<MembresiaProvider>();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          height: 130,
          width: double.infinity,
          color: Theme.of(context).colorScheme.secondary,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    "Mi Subscripcion",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 30.0),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                membresia.nombreMembresia,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                membresia.descripcion,
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
                      text: membresia.costo.toString(),
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              FutureBuilder<Map<String, dynamic>?>(
                future: membersiaProvider
                    .getOrigenMembresia(membresia.origenMembresia),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final origen = snapshot.data!;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Subscripción ',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                TextSpan(
                                  text: '${origen['origenTipo']}',
                                  style: const TextStyle(
                                      fontSize: 20.0, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${origen['nombreOrigen']}',
                            style: const TextStyle(
                                fontSize: 18.0, color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
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
