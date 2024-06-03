import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/Screens/Gimnasio/gimnasio_screen.dart';
import 'package:fitsolutions/Screens/Home/home_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Profile/perfil_screen.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/UserData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FooterBottomNavigationBar extends StatefulWidget {
  final ScreenType initialScreen;
  const FooterBottomNavigationBar({super.key, required this.initialScreen});

  @override
  State<FooterBottomNavigationBar> createState() =>
      _FooterBottomNavigationBarState();
}

class _FooterBottomNavigationBarState extends State<FooterBottomNavigationBar> {
  int _selectedIndex = 0;
  List<Widget> _screens = [];

  final prefs = SharedPrefsHelper();
  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserData>();

    if (userProvider.esBasico()) {
      _screens = [
        const EjerciciosScreen(),
        const PerfilScreen(),
        const HomeScreen(),
        const DietasScreen(),
        const MembresiaScreen()
      ];
    } else {
      _screens = [
        const GimnasioScreen(),
        const HomeScreen(),
        const DietasScreen(),
        const MembresiaScreen()
      ];
    }

    List<BottomNavigationBarItem> getBotones() {
      if (userProvider.esBasico()) {
        return <BottomNavigationBarItem>[
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
        ];
      } else {
        return <BottomNavigationBarItem>[
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
    }

    return Consumer<UserData>(
        builder: (context, value, child) => CupertinoTabBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              items: getBotones(),
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
