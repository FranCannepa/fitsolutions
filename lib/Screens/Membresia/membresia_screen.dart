import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_payment_service.dart';

class Membresia {
  final String nombre;
  final double precio;

  Membresia({required this.nombre, required this.precio});
}

final List<Membresia> membresias = [
  Membresia(nombre: 'Membresía Básica', precio: 50.0),
  Membresia(nombre: 'Membresía Estándar', precio: 100.0),
  Membresia(nombre: 'Membresía Premium', precio: 150.0),
];

class MembresiaScreen extends StatefulWidget {
  const MembresiaScreen({super.key});

  @override
  State<MembresiaScreen> createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen> {
  final PaymentService _paymentService = PaymentService(); // Instancia del servicio de pago

  void handlePayment(double amount) {
    _paymentService.createPayment(context, amount, 'cliente1@correo.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membresías'),
      ),
      body: ListView.builder(
        itemCount: membresias.length,
        itemBuilder: (context, index) {
          final membresia = membresias[index];
          return ListTile(
            title: Text(membresia.nombre),
            subtitle: Text('\$${membresia.precio.toStringAsFixed(2)}'),
            trailing: ElevatedButton(
              onPressed: () {
                handlePayment(membresia.precio);
              },
              child: Text('Pagar'),
            ),
          );
        },
      ),
    );
  }
}
