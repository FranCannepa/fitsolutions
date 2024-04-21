import 'package:fitsolutions/Components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/Components/RegisterComponents/registro_componentes.dart';
import 'package:fitsolutions/Screens/Home/homeScreen.dart';
import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  Future<void> handleRegister(String email, String password) async {
   
    print("PRESIONADO REGISTRO BUTTON");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ScreenTitle(title: "Crea tu cuenta"),
          FormRegistro(onSubmit: handleRegister),
        ],
      ),
    ));
  }
}
