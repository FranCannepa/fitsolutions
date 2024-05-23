import 'package:firebase_core/firebase_core.dart';
import 'package:fitsolutions/Modelo/user_data.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/screens/Login/login_email_screen.dart';
import 'package:fitsolutions/screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Utilities/navigator_service.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserData(),
        ),
        ChangeNotifierProvider(create: (context) => UserProvider())
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        theme: lightTheme,
        home: Consumer<UserProvider>(
          builder: (BuildContext context, UserProvider value,_) {
                  if(value.isAuthenticated && !value.firstLogin){
                    return const HomeScreen();
                  }else if(value.isAuthenticated && value.firstLogin){
                    return const RegistroScreen();
                  }
                  else{
                    return const LoginPage();
                  }
            },),   
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
