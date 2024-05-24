import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/navigator_service.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/RegisterComponents/basico_form.dart';
import 'package:fitsolutions/components/RegisterComponents/entrenador_form.dart';
import 'package:fitsolutions/components/RegisterComponents/propietario_form.dart';
import 'package:fitsolutions/modelo/UserData.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  String selectedOption = '';
  bool showForm = false;

  Future<void> registerUser(Map<String, dynamic> userData) async {
    final userProvider = context.read<UserData>();
    final prefs = SharedPrefsHelper();
    Logger log = Logger();
    try {
      userData['email'] = userProvider.email;
      userData['profilePic'] = userProvider.photoUrl;
      userProvider.updateUserData(userData);
      final docRef =
          await FirebaseFirestore.instance.collection('usuario').add(userData);
      prefs.setEmail(userProvider.email);
      prefs.setLoggedIn(true);
      prefs.setDocId(docRef.id);
      NavigationService.instance.pushNamed("/home");
    } on FirebaseException catch (e) {
      log.d(e.code);
      log.d(e.message);
    }
  }

  void handleOptionSelected(String option) {
    setState(() {
      selectedOption = option;
      showForm = true;
    });
  }

  void handleBackButtonPressed() {
    setState(() {
      selectedOption = '';
      showForm = false;
    });
  }

  Widget buildForm() {
    switch (selectedOption) {
      case 'Quiero entrenar':
        return BasicoForm(registerFunction: registerUser);
      case 'Soy propietario':
        return PropietarioForm(registerFunction: registerUser);
      case 'Soy entrenador':
        return EntrenadorForm(registerFunction: registerUser);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, value, child) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !showForm
                  ? Column(
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              handleOptionSelected('Quiero entrenar'),
                          child: const Text('Quiero entrenar'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () =>
                              handleOptionSelected('Soy propietario'),
                          child: const Text('Soy propietario'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () =>
                              handleOptionSelected('Soy entrenador'),
                          child: const Text('Soy entrenador'),
                        ),
                      ],
                    )
                  : const SizedBox(),
              showForm
                  ? Column(
                      children: [
                        buildForm(),
                        TextButton(
                          onPressed: handleBackButtonPressed,
                          child:
                              const Text('Seleccionar otro tipo de registro'),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
