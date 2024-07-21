import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/Screens/Gimnasio/gimnasio_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Registro/registro_screen.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/components/MembresiaComponents/membresia_detailed_dialog.dart';
import 'package:fitsolutions/providers/chart_provider.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/providers/inscription_provider.dart';
import 'package:fitsolutions/providers/notification_provider.dart';
import 'package:fitsolutions/providers/notification_service.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/purchases_provider.dart';
import 'package:fitsolutions/screens/Inscription/form_inscription_screen.dart';
import 'package:fitsolutions/screens/Inscription/inscription_screen.dart';
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

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService.initializeLocalNotifications();
  await NotificationService.initializeFirebaseMessaging();
  if (Platform.isIOS) {
    NotificationService().requestIOSPermissions();
  }

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
            create: (context) => FitnessProvider(FirebaseFirestore.instance)),
        ChangeNotifierProvider<InscriptionProvider>(
            create: (context) => InscriptionProvider(
                FirebaseFirestore.instance, NotificationService())),
        ChangeNotifierProvider<GimnasioProvider>(
            create: (context) => GimnasioProvider(FirebaseFirestore.instance)),
        ChangeNotifierProvider<NotificationProvider>(
            create: (context) =>
                NotificationProvider(FirebaseFirestore.instance)),
        ChangeNotifierProvider<ActividadProvider>(
            create: (context) => ActividadProvider()),
        ChangeNotifierProvider<MembresiaProvider>(
            create: (context) => MembresiaProvider()),
        ChangeNotifierProvider<DietaProvider>(
            create: (context) => DietaProvider()),
        ChangeNotifierProvider(
            create: (context) => ChartProvider(FirebaseFirestore.instance)),
        ChangeNotifierProvider<PurchasesProvider>(
            create: (context) => PurchasesProvider()),
        
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        navigatorObservers: [
          WidgetBindingsObserverSample(),
        ],
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
                SharedPrefsHelper().initializeData();
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
          '/welcome': (BuildContext context) => const WelcomePage(),
          '/inscription': (BuildContext context) => const InscriptionScreen(),
          '/form_inscription': (BuildContext context) =>
              const FormInscriptionScreen(),
        },
      ),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //print('Handling a background message: ${message.messageId}');
}
