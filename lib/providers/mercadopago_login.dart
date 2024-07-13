import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logger/logger.dart';

const String CLIENT_ID = '491143852095789';
const String CLIENT_SECRET = 'Ev29l3aTidRxxoQwC9hDeAPEGc47l92G';
const String REDIRECT_URI = 'https://anichart.net/Summer-2024';
const String AUTHORIZATION_ENDPOINT = 'https://auth.mercadopago.com.uy/authorization';
const String TOKEN_ENDPOINT = 'https://api.mercadopago.com/oauth/token';

const FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

class MercadoPagoLoginPage extends StatelessWidget {
  const MercadoPagoLoginPage({super.key});

  Future<void> login(BuildContext context) async {
    try {
      final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          CLIENT_ID,
          REDIRECT_URI,
          clientSecret: CLIENT_SECRET,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: AUTHORIZATION_ENDPOINT,
            tokenEndpoint: TOKEN_ENDPOINT,
          ),
          scopes: ['offline_access'],
        ),
      );

      if (result != null) {
        final String accessToken = result.accessToken!;
        final String refreshToken = result.refreshToken!;

        await secureStorage.write(key: 'accessToken', value: accessToken);
        await secureStorage.write(key: 'refreshToken', value: refreshToken);

        // Save tokens in Firestore or your backend database
        saveCredentialsToFirestore(accessToken, refreshToken);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    } catch (e) {
      Logger().d(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),

      );
    }
  }

  Future<void> saveCredentialsToFirestore(String accessToken, String refreshToken) async {
    // Implement saving to Firestore or your backend database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MercadoPago Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => login(context),
          child: const Text('Login with MercadoPago'),
        ),
      ),
    );
  }
}
