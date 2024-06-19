import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:fitsolutions/Components/CalendarComponents/calendarioDisplayer.dart';
//import 'package:fitsolutions/Components/components.dart';
//import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/providers/user_provider.dart';
//import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/screens/Gimnasio/gimnasio_screen.dart';
import 'package:fitsolutions/screens/Home/home_screen_content.dart';
import 'package:fitsolutions/screens/Login/welcome_screen.dart';
//import 'package:fitsolutions/screens/Login/welcome_screen.dart';
import 'package:fitsolutions/screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/screens/Plan/plan_screen.dart';
import 'package:fitsolutions/screens/Profile/perfil_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendario_agregar_actividad_dialog.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendario_displayer.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _initializeScreenIndex() async {
    final userProvider = context.read<UserData>();
    _selectedIndex =
        userProvider.esBasico() ? 2 : 1; // Set index based on user's status
  }

  @override
  void initState() {
    super.initState();
    _initializeScreenIndex();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = SharedPrefsHelper();
    try {
      final docRef = FirebaseFirestore.instance
          .collection('usuario')
          .doc(await prefs.getUserId());
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        NavigationService.instance.pushNamed("/login");
      }
    } catch (e) {
      return null;
    }
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userProvider = context.read<UserData>();

            List<Widget> screens = userProvider.esBasico()
                ? [
                    const EjerciciosScreen(),
                    const PerfilScreen(),
                    const HomeScreenContent(), // Separate widget for home screen content
                    const DietasScreen(),
                    MembresiaScreen(provider: userProvider),
                  ]
                : [
                    const GimnasioScreen(),
                    const HomeScreenContent(), // Separate widget for home screen content
                    const DietasScreen(),
                    MembresiaScreen(provider: userProvider),
                    const PlanScreen(),
                  ];

            List<BottomNavigationBarItem> getBotones() {
              return userProvider.esBasico()
                  ? [
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/dumbell_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/profile_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/home_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/diet_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/membership_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ]
                  : [
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/dumbell_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/home_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/diet_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/membership_icon.png'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ];
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                automaticallyImplyLeading:
                    false, // This removes the back button
                actions: [
                  IconButton(
                    onPressed: () async {
                      UserProvider userProvider = context.read<UserProvider>();
                      await userProvider.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const WelcomePage(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: screens,
                ),
              ),
              bottomNavigationBar: CupertinoTabBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                items: getBotones(),
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                currentIndex: _selectedIndex,
              ),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text("Error fetching user data!"),
              ),
            );
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }
      )
    );
  }
}