import 'dart:convert';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  Future<String?> createURL(BuildContext context, double amount, String email,
      String membresiaId, String asociadoId) async {
    final MembresiaProvider membresiaProvider =
        context.read<MembresiaProvider>();

    try {
      final keys = await membresiaProvider.getKeys(asociadoId);
      final publicKey = keys['publicKey'];
      final accessToken = keys['accessToken'];

      if (publicKey == null || accessToken == null) {
        throw Exception('Missing API keys');
      }

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
          'installments': 1,
        },
        'back_urls': {
          'success': 'com.fitsolutions.fitsolutionsapp://success',
          'failure': 'com.fitsolutions.fitsolutionsapp://failure',
          'pending': 'com.fitsolutions.fitsolutionsapp://pending',
        },
        'auto_return': 'approved',
        'notification_url':
            'https://webhook.site/#!/view/81f9d1c6-f02d-4d92-b0f2-3167b23e69c8/fd608e45-dadb-4327-9202-911960e15fe5/1',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestPayload),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final String initPoint = responseData['init_point'];
        final String preferenceId = responseData['id'];
        final Uri pagoUrl = Uri.parse(initPoint);

        return pagoUrl.toString();
      } else {
        return null;
      }
    } catch (error) {
      print('Error creating URL: $error');
      return null;
    }
  }

  Future<void> createPayment(BuildContext context, double amount, String email,
      String membresiaId, String asociadoId) async {
    final MembresiaProvider membresiaProvider =
        context.read<MembresiaProvider>();

    final keys = await membresiaProvider.getKeys(asociadoId);
    final publicKey = keys['publicKey']!;
    final accessToken = keys['accessToken']!;

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
        'installments': 1,
      },
      'back_urls': {
        'success': 'com.fitsolutions.fitsolutionsapp://success',
        'failure': 'com.fitsolutions.fitsolutionsapp://failure',
        'pending': 'com.fitsolutions.fitsolutionsapp://pending',
      },
      'auto_return': 'approved',
      'notification_url':
          'https://webhook.site/#!/view/81f9d1c6-f02d-4d92-b0f2-3167b23e69c8/fd608e45-dadb-4327-9202-911960e15fe5/1',
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestPayload),
    );
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final String initPoint = responseData['init_point'];
      final String preferenceId = responseData['id'];
      final Uri pagoUrl = Uri.parse(initPoint);

      if (await canLaunchUrl(pagoUrl)) {
        await launchUrl(pagoUrl);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_membresia_id', membresiaId);
        await prefs.setString('pending_preference_id', preferenceId);
      } else {
        print('No se pudo abrir el enlace de pago: $initPoint');
        throw 'No se pudo abrir el enlace de pago.';
      }
    } else {
      print('Error en el pago: ${response.body}');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error en el pago')));
    }
  }

  Future<void> verifyPayment(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? payment_id = prefs.getString('pending_payment_id');
    final String? membresiaId = prefs.getString('pending_membresia_id');

    if (payment_id == null || membresiaId == null) {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay pagos pendientes')));
      return;
    }

    final UserData userProvider = context.read<UserData>();
    final MembresiaProvider membresiaProvider =
        context.read<MembresiaProvider>();
    final gimnasioId = userProvider.gimnasioId;

    final keys = await membresiaProvider.getKeys(gimnasioId);
    final accessToken = keys['accessToken']!;

    final url = 'https://api.mercadopago.com/v1/payments/$payment_id';

    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final String? status = responseData['status'];

      if (status != null && status == 'approved') {
        final UserData userProvider = context.read<UserData>();
        await userProvider.updateMembresiaId(membresiaId);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pago exitoso y membresía asignada')));
        Navigator.pushReplacementNamed(context, '/membresia');
        await prefs.remove('pending_membresia_id');
        await prefs.remove('pending_payment_id');
      } else if (status == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pago pendiente de membresia')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pago fallido')));
        await prefs.remove('pending_membresia_id');
        await prefs.remove('pending_payment_id');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error verificando el pago')));
    }
  }
}
