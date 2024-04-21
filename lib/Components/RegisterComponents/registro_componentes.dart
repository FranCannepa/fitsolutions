import 'package:flutter/material.dart';

class FormRegistro extends StatefulWidget {
  const FormRegistro({Key? key, required this.onSubmit}) : super(key: key);

  final Function(String email, String password) onSubmit;

  @override
  _FormRegistroState createState() => _FormRegistroState();
}

class _FormRegistroState extends State<FormRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                icon: Icon(Icons.mail),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese un correo electrónico válido';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                icon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese una contraseña';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextFormField(
              controller: _rePasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirme contraseña',
                icon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirme su contraseña';
                }
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () {
              widget.onSubmit(_emailController.text, _passwordController.text);
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                    _emailController.text, _passwordController.text);
              }
            },
            child: const Text('Registrarse'),
          ),
        ],
      ),
    );
  }
}
