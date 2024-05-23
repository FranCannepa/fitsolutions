import 'package:fitsolutions/Components/CalendarComponents/calendario_board.dart';
import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
              key: const Key('sign_out'),
              onPressed: () {
                userProvider.signOut();
              },
              icon: const Icon(Icons.logout_outlined))
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CalendarioBoard()],
        ),
      ),
      bottomNavigationBar: const FooterBottomNavigationBar(),
    );
  }
}
