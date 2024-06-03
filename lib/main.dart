import 'package:firebase_core/firebase_core.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/Screens/Gimnasio/gimnasio_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitsolutions/screens/Home/home_screen.dart';
import 'package:fitsolutions/screens/Profile/perfil_screen.dart';
import 'package:fitsolutions/Theme/light_theme.dart';
import 'package:fitsolutions/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  UserData().initializeData();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserData>(create: (context) => UserData()),
      ChangeNotifierProvider(create: (context) => UserProvider()),
    ],
    child: MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      theme: lightTheme,
      home: FutureBuilder<bool>(
        future: SharedPrefsHelper().getLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            context.read<UserData>().initializeData();
            return const HomeScreen();
          }
          return const WelcomePage();
        },
      ),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomeScreen(),
        '/login': (BuildContext context) => const WelcomePage(),
        '/perfil': (BuildContext context) => const PerfilScreen(),
        '/dieta': (BuildContext context) => const DietasScreen(),
        '/ejercicios': (BuildContext context) => const EjerciciosScreen(),
        '/membresia': (BuildContext context) => const MembresiaScreen(),
        '/registro': (BuildContext context) => const RegistroScreen(),
        '/gimnasio': (BuildContext context) => const GimnasioScreen(),
        '/welcome': (BuildContext context) => const WelcomePage()
      },
    ),
  ));
}
