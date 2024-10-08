import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/screens/Gimnasio/gimnasio_screen.dart';
import 'package:fitsolutions/screens/Home/home_screen_content.dart';
import 'package:fitsolutions/screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/screens/Plan/plan_screen.dart';
import 'package:fitsolutions/screens/Profile/perfil_screen.dart';
import 'package:flutter/cupertino.dart';

import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final int index;
  const HomeScreen({super.key, this.index = 99});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Logger log = Logger();
  bool? esBasico;

  Future<void> _initializeScreenIndex() async {
    final userProvider = context.read<UserData>();
    if (widget.index == 99) {
      _selectedIndex = userProvider.esBasico() ? 2 : 1;
    } else {
      setState(() {
        _selectedIndex = widget.index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeScreenIndex();
    _initializeFCM();
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

  Future<void> _initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      _sendTokenToServer(token);
    } else {
      log.d('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log.d('Received a message in the foreground: ${message.messageId}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log.d('Message clicked!');
    });
  }

  Future<void> _sendTokenToServer(String? token) async {
    final prefs = SharedPrefsHelper();
    String? userId = await prefs.getUserId();
    FirebaseFirestore.instance
        .collection('usuario')
        .doc(userId!)
        .update({'fcmToken': token});
  }

  @override
  Widget build(BuildContext context) {
    final actividadProvider = context.read<ActividadProvider>();
    context.watch<GimnasioProvider>();
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
                        HomeScreenContent(actividadProvider: actividadProvider),
                        const DietasScreen(),
                        MembresiaScreen(provider: userProvider),
                      ]
                    : [
                        const GimnasioScreen(),
                        HomeScreenContent(actividadProvider: actividadProvider),
                        const DietasScreen(),
                        MembresiaScreen(provider: userProvider),
                        const PlanScreen(),
                      ];

                List<BottomNavigationBarItem> getBotones() {
                  return userProvider.esBasico()
                      ? [
                          BottomNavigationBarItem(
                            icon: Image.asset('assets/icons/dumbell_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          BottomNavigationBarItem(
                            icon: Image.asset('assets/icons/profile_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          BottomNavigationBarItem(
                            icon: Image.asset('assets/icons/home_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          BottomNavigationBarItem(
                            icon: Image.asset('assets/icons/diet_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          BottomNavigationBarItem(
                            icon:
                                Image.asset('assets/icons/membership_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ]
                      : [
                          BottomNavigationBarItem(
                            icon: Image.asset('assets/icons/dumbell_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          BottomNavigationBarItem(
                            icon: Image.asset('assets/icons/home_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          BottomNavigationBarItem(
                            icon: Image.asset('assets/icons/diet_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          BottomNavigationBarItem(
                            icon:
                                Image.asset('assets/icons/membership_icon.png',width: 30,height: 30),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ];
                }

                return Scaffold(
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
            }));
  }
}
