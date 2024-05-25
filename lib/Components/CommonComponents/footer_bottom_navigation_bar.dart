import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/Screens/Dietas/dietas_screen.dart';
import 'package:fitsolutions/Screens/Ejercicios/ejercicios_screen.dart';
import 'package:fitsolutions/Screens/Gimnasio/gimnasio_screen.dart';
import 'package:fitsolutions/Screens/Home/home_screen.dart';
import 'package:fitsolutions/Screens/Membresia/membresia_screen.dart';
import 'package:fitsolutions/Screens/Profile/perfil_screen.dart';
import 'package:fitsolutions/modelo/UserData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FooterBottomNavigationBar extends StatefulWidget {
  const FooterBottomNavigationBar({super.key, required this.initialScreen});
  final ScreenType initialScreen;

  @override
  State<FooterBottomNavigationBar> createState() =>
      _FooterBottomNavigationBarState();
}

class _FooterBottomNavigationBarState extends State<FooterBottomNavigationBar> {
  int _selectedIndex = 0;
  Widget? _currentScreen;

  List<Widget> _getAvailableScreens(UserData userProvider) {
    if (userProvider.esBasico()) {
      return [
        const EjerciciosScreen(),
        const PerfilScreen(),
        const HomeScreen(),
        const DietasScreen(),
        const MembresiaScreen(),
      ];
    } else {
      return [
        const EjerciciosScreen(),
        const PerfilScreen(),
        const HomeScreen(),
        const DietasScreen(),
        const MembresiaScreen(),
        const GimnasioScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserData>();

    return Consumer<UserData>(
      builder: (context, value, child) => CupertinoTabBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        items: [
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
          if (userProvider.esPropietario())
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/dumbell2_icon.png'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
        ],
        onTap: (index) {
          final currentScreen = _getAvailableScreens(userProvider)[index];
          if (_currentScreen == currentScreen) {
            if (currentScreen is HomeScreen) {}
            return;
          }
          setState(() {
            _selectedIndex = index;
            _currentScreen = currentScreen;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _currentScreen!,
            ),
          );
        },
        currentIndex: _selectedIndex == widget.initialScreen.index
            ? _selectedIndex
            : widget.initialScreen.index,
      ),
    );
  }
}
