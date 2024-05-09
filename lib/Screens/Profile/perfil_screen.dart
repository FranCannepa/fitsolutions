import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key, this.Usuario}) : super(key: key);
  final Usuario;

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 50.0,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Nombre Completo',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const Text('Usuario de Ejemplo'),
              const SizedBox(height: 16.0),
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edad'),
                        Text('30 años'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Peso'),
                        Text('75 kg'), // Reemplaza con peso real
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Altura'),
                        Text('1.80 m'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo de Sangre'),
                        Text('A+'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Intereses',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const Text('Flutter, Desarrollo de Apps, Diseño UI/UX'),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Navegar a pantalla de edición de perfil (implementar)
                },
                child: const Text('Editar Perfil'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FooterBottomNavigationBar(),
    );
  }
}
