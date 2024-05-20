import 'package:firebase_core/firebase_core.dart';
import 'package:fitsolutions/Modelo/user_data.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Utilities/navigator_service.dart';
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
  final userData = UserData();
  runApp(
    ChangeNotifierProvider<UserData>(
      create: (context) => userData,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      theme: lightTheme,
      home: const LoginScreen(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomeScreen(),
        '/login': (BuildContext context) => const LoginScreen(),
        '/perfil': (BuildContext context) => const PerfilScreen(),
        '/dieta': (BuildContext context) => const DietasScreen(),
        '/membresia': (BuildContext context) => const MembresiaScreen(),
        '/registro': (BuildContext context) => const RegistroScreen(),
      },
    );
  }
}
