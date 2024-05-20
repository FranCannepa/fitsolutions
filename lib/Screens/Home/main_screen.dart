import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Screens/Home/home_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user; // Track the currently logged-in user

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser; // Check for existing logged-in user
  }
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body:
            HomeScreen() //_user != null ? const HomeScreen() : const LoginScreen(),
        );
  }
}
