

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
