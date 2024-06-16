import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigator.dart';
import 'package:fitsolutions/Components/ProfileComponents/perfilDetailed.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/userData.dart';
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
    final userProvider = context.read<UserData>();
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
      bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.perfil,
      ),
    ));
  }
}
