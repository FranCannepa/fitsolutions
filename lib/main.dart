import 'package:firebase_core/firebase_core.dart';
import 'package:fitsolutions/Modelo/UserData.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitsolutions/Screens/Home/home_screen.dart';
import 'package:fitsolutions/Screens/Login/login_screen.dart';
import 'package:fitsolutions/Screens/Profile/perfil_screen.dart';
import 'package:fitsolutions/Theme/light_theme.dart';
import 'package:fitsolutions/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create a single instance of UserData for the entire app
  final userData = UserData();

  runApp(
    // Wrap MaterialApp with ChangeNotifierProvider to expose UserData
    ChangeNotifierProvider<UserData>(
      create: (context) => userData,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      home: const LoginScreen(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomeScreen(),
        '/login': (BuildContext context) => const LoginScreen(),
        '/perfil': (BuildContext context) => const PerfilScreen(),
        '/dieta': (BuildContext context) => const DietasScreen(),
        '/ejercicios': (BuildContext context) => const EjerciciosScreen(),
        '/membresia': (BuildContext context) => const MembresiaScreen(),
      },
    );
  }
}
