import 'dart:developer';

import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/userData.dart';
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

  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();
    if (userProvider.esBasico()) {
      _screens = [
        '/ejercicios',
        '/perfil',
        '/home',
        '/dieta',
        '/membresia',
      ];
    } else {
      _screens = [
        //'/plan',
        '/gimnasio',
        '/home',
        '/dieta',
        '/membresia',
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
        builder: (context, userData, child) => CupertinoTabBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              items: getBotones(),
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  Navigator.pushNamed(
                    context,
                    _screens[_selectedIndex],
                  );
                });
              },
              currentIndex: _selectedIndex,
            ));
  }
}
