import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  final Object? userData;
  const RegistroScreen({super.key, required this.userData});

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  void navigateToEntrenadorForm() {
    print('Navigate to Entrenador form');
  }

  void navigateToPropietarioForm() {
    print('Navigate to Propietario form');
  }

  void navigateToClienteForm() {
    print('Navigate to Cliente form');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, 
            children: [
              ElevatedButton(
                onPressed: navigateToEntrenadorForm,
                child: const Text('Quiero entrenar'),
              ),
              const SizedBox(height: 10), // Add spacing between buttons
              ElevatedButton(
                onPressed: navigateToPropietarioForm,
                child: const Text('Soy propietario'),
              ),
              const SizedBox(height: 10), // Add spacing between buttons
              ElevatedButton(
                onPressed: navigateToClienteForm,
                child: const Text('Soy entrenador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
