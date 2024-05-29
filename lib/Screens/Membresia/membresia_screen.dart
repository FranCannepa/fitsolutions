import 'package:fitsolutions/Components/MembresiaComponents/membresiaDisplayerPropietario.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaDisplayerBasico.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/modelo/UserData.dart';
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

    Widget getMembresiaScren() {
      if (userProvider.esBasico()) {
        return const MembresiaDisplayerBasico();
      } else if (userProvider.esPropietario()) {
        return const MembresiaDisplayerPropietario();
      } else {
        return const MembresiaDisplayerPropietario();
      }
    }
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
