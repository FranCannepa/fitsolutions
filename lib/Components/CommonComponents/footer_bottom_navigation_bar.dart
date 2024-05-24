import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/Screens/Gimnasio/gimnasio_screen.dart';
import 'package:fitsolutions/Screens/Home/home_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Profile/perfil_screen.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FooterBottomNavigationBar extends StatefulWidget {
  const FooterBottomNavigationBar({super.key});

  @override
  State<FooterBottomNavigationBar> createState() =>
      _FooterBottomNavigationBarState();
}

class _FooterBottomNavigationBarState extends State<FooterBottomNavigationBar> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const EjerciciosScreen(),
    const PerfilScreen(),
    const HomeScreen(),
    const DietasScreen(),
    const MembresiaScreen(),
    const GimnasioScreen()
  ];

  final prefs = SharedPrefsHelper();
  @override
  Widget build(BuildContext context) {

    return Consumer<UserData>(
        builder: (context, value, child) => CupertinoTabBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              items: <BottomNavigationBarItem>[
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
                BottomNavigationBarItem(
                  icon: Image.asset('assets/icons/dumbell2_icon.png'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _screens[index]),
                  );
                });
              },
              currentIndex: _selectedIndex,
            ));
  }
}
