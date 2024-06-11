import 'package:fitsolutions/Components/CalendarComponents/calendarioDisplayer.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CalendarioDisplayer(),
      bottomNavigationBar: FooterBottomNavigationBar(
        initialScreen: ScreenType.home,
      ),
    );
  }
}
