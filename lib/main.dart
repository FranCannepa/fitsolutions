import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/Screens/Gimnasio/gimnasio_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/screens/Login/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitsolutions/screens/Home/home_screen.dart';
import 'package:fitsolutions/screens/Profile/perfil_screen.dart';
import 'package:fitsolutions/Theme/light_theme.dart';
import 'package:fitsolutions/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/providers/userData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool>? isLoggedIn() async {
    return await SharedPrefsHelper().getLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>(create: (context) => UserData()),
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider()),
        ChangeNotifierProvider<FitnessProvider>(
            create: (context) => FitnessProvider()),
        ChangeNotifierProvider<ActividadProvider>(
            create: (context) => ActividadProvider()),
        ChangeNotifierProvider<MembresiaProvider>(
            create: (context) => MembresiaProvider())
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        theme: lightTheme,
        home: FutureBuilder<bool>(
          future: SharedPrefsHelper().getLoggedIn(),
          builder: (context, snapshot) {
            final userProvider = context.read<UserData>();
            if (snapshot.hasData && snapshot.data == true) {
              SharedPrefsHelper().initializeData();
              userProvider.initializeData();
              return const HomeScreen();
            }
            if (snapshot.hasData) {
              final isLoggedIn = snapshot.data!;
              if (isLoggedIn) {
                userProvider.initializeData();
              }
              final auth = context.read<UserProvider>();
              if (isLoggedIn && auth.firstLogin) {
                userProvider.firstLogin(auth.user!);
                return const RegistroScreen();
              }
              return isLoggedIn ? const HomeScreen() : const WelcomePage();
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => const HomeScreen(),
          '/login': (BuildContext context) => const WelcomePage(),
          '/perfil': (BuildContext context) => const PerfilScreen(),
          '/dieta': (BuildContext context) => const DietasScreen(),
          '/ejercicios': (BuildContext context) => const EjerciciosScreen(),
          '/membresia': (BuildContext context) => MembresiaScreen(
                provider: context.read<UserData>(),
              ),
          '/registro': (BuildContext context) => const RegistroScreen(),
          '/gimnasio': (BuildContext context) => const GimnasioScreen(),
          '/welcome': (BuildContext context) => const WelcomePage()
        },
      ),
    );
  }
}
