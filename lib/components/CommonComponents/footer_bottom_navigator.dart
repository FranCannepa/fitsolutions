import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/user_data.dart';
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
  List<String> _screens = [];
  void initRoutes(UserData provider) async {
    final esBasico = await provider.rutasBasico();
    if (esBasico) {
      _screens = [
        '/ejercicios',
        '/perfil',
        '/home',
        '/dieta',
        '/membresia',
      ];
    } else {
      _screens = [
        '/gimnasio',
        '/home',
        '/dieta',
        '/membresia',
      ];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();
    userProvider.initializeData();
    initRoutes(userProvider);
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
      builder: (context, userData, child) => CupertinoTabBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        items: getBotones(),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            Navigator.pushNamed(context, _screens[_selectedIndex]);
          });
        },
        currentIndex: _selectedIndex,
        activeColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
