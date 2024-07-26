//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:fitsolutions/Components/components.dart';
//import 'package:fitsolutions/Modelo/Screens.dart';
//import 'package:fitsolutions/Screens/Profile/editar_perfil_screen.dart';
//import 'package:fitsolutions/Utilities/formaters.dart';
//import 'package:fitsolutions/modelo/models.dart';
//import 'package:fitsolutions/screens/Inscription/form_inscription_screen.dart';
//import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigator.dart';
import 'package:fitsolutions/Components/ProfileComponents/perfilDetailed.dart';
//import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserData>();
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: userProvider.getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!;
              return PerfilDetailed(userData: userData);
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Error fetching user data!"),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      /*bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.perfil,
      ),*/
    ));
  }
}
