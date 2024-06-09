import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  final String publicKey = 'TEST-124afa4a-2c3a-4f39-8581-e04bfad8cef5';
  final String accessToken = 'TEST-1628838184153243-060209-074d7ed4fad500e2ee654b2d6efc4aac-237628568';

  Future<void> createPayment(BuildContext context, double amount, String email) async {
    final url = 'https://api.mercadopago.com/checkout/preferences?access_token=$accessToken';

    final Map<String, dynamic> requestPayload = {
      'items': [
        {
          'title': 'Membresía de Gimnasio',
          'description': 'Pago de membresía',
          'quantity': 1,
          'currency_id': 'UYU',
          'unit_price': amount,
        }
      ],
      'payer': {
        'email': email,
      },
      'payment_methods': {
        'excluded_payment_methods': [],
        'excluded_payment_types': [],
        'installments': 1, // Número máximo de cuotas
      },
      'back_urls': {
        'success': 'https://www.google.com/',
        'failure': 'https://www.google.com/',
        'pending': 'https://www.google.com/',
      },
      'auto_return': 'approved',
    };

    print('Request Payload: ${json.encode(requestPayload)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestPayload),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final String initPoint = responseData['init_point'];

      print('Init Point: $initPoint');

      final Uri pagoUrl = Uri.parse(initPoint);

      // Redirigir al usuario al init_point para completar el pago
      if (await canLaunchUrl(pagoUrl)) {
        await launchUrl(pagoUrl);
      } else {
        print('No se pudo abrir el enlace de pago: $initPoint');
        throw 'No se pudo abrir el enlace de pago.';
      }
    } else {
      // Manejar error
      print('Error en el pago: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error en el pago')));
    }
  }
}
