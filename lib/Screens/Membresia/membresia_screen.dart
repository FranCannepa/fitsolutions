import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaScreen extends StatefulWidget {
  const MembresiaScreen({super.key});

  @override
  State<MembresiaScreen> createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen> {
  bool showMembresiaForm = false;
  void refreshScreen() async {
    setState(() {
      showMembresiaForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserData>();

    return Scaffold(
      body: userProvider.esBasico()
          ? const MembresiaDisplayerBasico()
          : const MembresiaDisplayerPropietario(),
      bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.membresia,
      ),
    );
  }
}
