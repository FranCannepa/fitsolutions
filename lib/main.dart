// import 'package:fitsolutions/Screens/Home/HomeScreen.dart';
import 'package:fitsolutions/Screens/Home/homeScreen.dart';
import 'package:fitsolutions/Screens/Login/login_screen.dart';
import 'package:fitsolutions/Screens/Profile/perfilUsuarioBasico.dart';
import 'package:fitsolutions/Screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Theme/light_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      home: const LoginScreen(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => HomeScreen(),
        '/registro': (BuildContext context) => RegistroScreen(),
        '/login': (BuildContext context) => LoginScreen(),
        '/perfil': (BuildContext context) => DailyActivityScreen()
        // '/calendario' (BuildContext context) => CalendarioSCr(),
      },
    );
  }
}
