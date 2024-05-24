import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
import 'package:fitsolutions/Modelo/user_data.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/repository/user_repository.dart';
import 'package:fitsolutions/repository/user_repository_imp.dart';
import 'package:fitsolutions/screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/screens/Plan/plan_screen.dart';
import 'package:fitsolutions/screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Utilities/navigator_service.dart';
import 'package:fitsolutions/screens/splash_screen.dart';
=======
import 'package:fitsolutions/Modelo/UserData.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Utilities/NavigatorService.dart';
>>>>>>> parent of 393f28a (Ajuste de nomeclatura Flutter)
import 'package:flutter/material.dart';
import 'package:fitsolutions/screens/Home/home_screen.dart';
import 'package:fitsolutions/screens/Login/login_screen.dart';
import 'package:fitsolutions/screens/Profile/perfil_screen.dart';
import 'package:fitsolutions/Theme/light_theme.dart';
import 'package:fitsolutions/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(UserRepositoryImp()));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp(this.userRepository,{super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserData(),
        ),
        ChangeNotifierProvider(create: (context) => UserProvider(userRepository: userRepository))
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
