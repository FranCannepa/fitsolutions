import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GimnasioScreen extends StatefulWidget {
  const GimnasioScreen({super.key});
  @override
  State<GimnasioScreen> createState() => _GimnasioScreenState();
}

class _GimnasioScreenState extends State<GimnasioScreen> {
  @override
  Widget build(BuildContext context) {
    final gimnasioProvider = context.read<GimnasioProvider>();
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: gimnasioProvider.getGym(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final gimnasio = snapshot.data;
                if (gimnasio != null) {
                  return GimnasioInfo(gimnasio: gimnasio);
                } else {
                  return Text('No TENGO GYM');
                }
              } else {
                return Container();
              }
            }),
      ),
      bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.gym,
      ),
    );
  }
}
