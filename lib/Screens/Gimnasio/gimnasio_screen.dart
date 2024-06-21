import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/screens/Gimnasio/gym_detail_screen.dart';
import 'package:fitsolutions/screens/Gimnasio/gym_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class GimnasioScreen extends StatefulWidget {
  const GimnasioScreen({super.key});

  @override
  State<GimnasioScreen> createState() => _GimnasioScreenState();
}

class _GimnasioScreenState extends State<GimnasioScreen> {
  bool showGymForm = false;
  Logger log = Logger();
  bool? esEntrenador;

  @override
  void initState() {
    super.initState();
    esTrainer();
  }

  Future<void> esTrainer() async {
    final prefs = SharedPrefsHelper();
    esEntrenador = await prefs.esEntrenador();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GimnasioProvider>();

    return Scaffold(
      body: Center(
        child: FutureBuilder<Gimnasio?>(
          future: provider.getGym(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error fetching gym data: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data != null) {
              final gymData = snapshot.data!;
              return GymDetailScreen(gym: gymData);
            } else {
              return !showGymForm
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        esEntrenador!
                            ? const Text(
                                "No tienes informacion de entrenador asociado!",
                                style: TextStyle(fontSize: 18.0),
                              )
                            : const Text(
                                "No tienes ningun gimnasio asociado!",
                                style: TextStyle(fontSize: 18.0),
                              ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () => setState(() => showGymForm = true),
                          child: !esEntrenador! ? const Text("Registrar gimnasio") : const Text("Registar informacion"),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        GymRegistrationForm(
                          provider: provider,
                          onSubmit: () {
                            setState(() {
                              showGymForm = false;
                            });
                          },
                        ),
                      ],
                    );
            }
          },
        ),
      ),
    );
  }
}
