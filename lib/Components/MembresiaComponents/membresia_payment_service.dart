import 'dart:convert';
import 'package:fitsolutions/providers/userData.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  final String publicKey = 'TEST-124afa4a-2c3a-4f39-8581-e04bfad8cef5';
  final String accessToken =
      'TEST-1628838184153243-060209-074d7ed4fad500e2ee654b2d6efc4aac-237628568';

  Future<void> createPayment(
      BuildContext context, double amount, String email, String membresiaId) async {
    final url =
        'https://api.mercadopago.com/checkout/preferences?access_token=$accessToken';

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
        'success': 'myapp://success',
        'failure': 'myapp://failure',
        'pending': 'myapp://pending',
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
      final String preferenceId = responseData['id'];
      //final String status = responseData["status"];

      print('Init Point: $initPoint');

      final Uri pagoUrl = Uri.parse(initPoint);

      // Redirigir al usuario al init_point para completar el pago
      if (await canLaunchUrl(pagoUrl)) {
        await launchUrl(pagoUrl);

        //almaceno el id de la membresia y id del pago en sharedpreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_membresia_id', membresiaId);
        await prefs.setString('pending_preference_id', preferenceId);
        //await prefs.setString('status_membresia', status);

      } else {
        print('No se pudo abrir el enlace de pago: $initPoint');
        throw 'No se pudo abrir el enlace de pago.';
      }
    } else {
      // Manejar error
      print('Error en el pago: ${response.body}');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error en el pago')));
    }
  }

  Future<void> verifyPayment(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? preferenceId = prefs.getString('pending_preference_id');
    final String? membresiaId = prefs.getString('pending_membresia_id');

    if (preferenceId == null || membresiaId == null) {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay pagos pendientes')));
      return;
    }

    final url = 'https://api.mercadopago.com/checkout/preferences/$preferenceId';

    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final String? autoReturn = responseData['auto_return'];

      if (autoReturn != null && autoReturn == 'approved') {
        final UserData userProvider = context.read<UserData>();
        await userProvider.updateMembresiaId(membresiaId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago exitoso y membresía asignada')));

        Navigator.pushReplacementNamed(context, '/membresia');
      } else if (autoReturn == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago pendiente')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago fallido')));
      }

      await prefs.remove('pending_membresia_id');
      await prefs.remove('pending_preference_id');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error verificando el pago')));
    }
  }
}
