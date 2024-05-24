import 'package:firebase_core/firebase_core.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Utilities/navigator_service.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/UserData.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitsolutions/screens/Home/home_screen.dart';
import 'package:fitsolutions/screens/Profile/perfil_screen.dart';
import 'package:fitsolutions/Theme/light_theme.dart';
import 'package:fitsolutions/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final userData = UserData();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<UserData>(
      create: (context) => userData,
      child: const MyApp(),
    ),
  );
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
      ChangeNotifierProvider(create: (_) => UserProvider()
      ),
      ],
      child:MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      theme: lightTheme,
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error as Object);
          }
          if (snapshot.hasData) {
            final isLoggedIn = snapshot.data!;
            if (isLoggedIn) {
              final userProvider = context.read<UserData>();
              userProvider.initializeData();
            }
            return isLoggedIn ? const HomeScreen() : const LoginScreen();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomeScreen(),
        '/login': (BuildContext context) => const LoginScreen(),
        '/perfil': (BuildContext context) => const PerfilScreen(),
        '/dieta': (BuildContext context) => const DietasScreen(),
        '/membresia': (BuildContext context) => const MembresiaScreen(),
        '/registro': (BuildContext context) => const RegistroScreen(),
      },
    ),
    );
  }
}
