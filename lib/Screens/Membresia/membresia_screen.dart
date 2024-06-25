import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Membresia {
  final String nombre;
  final double precio;

  Membresia({required this.nombre, required this.precio});
}

class MembresiaScreen extends StatefulWidget {
  final UserData provider;
  const MembresiaScreen({super.key, required this.provider});

  @override
  State<MembresiaScreen> createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen> {
  
  @override
  void initState() {
    super.initState();
    initUnitLinks();
  }

  Future<void> initUnitLinks() async {
    //para manejar enlaces iniciales (cuando la app no esta en ejecuccion)
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    print('initUnitLinks ejecutandose');
    //para manejar enlaces en tiempo real (cuando la app ya esta en ejecuccion)external_reference
    linkStream.listen((String? link){
      if(link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print('Error: $err');
    });
  }

  void _handleDeepLink(String link) async {

    //recupero el estado anterior para evitar procesarlo muchas veces
    final prefs = await SharedPreferences.getInstance();
    final String? lastHandledLink = prefs.getString('last_handled_link');

    if (lastHandledLink == link) {
      return; // Si el enlace ya fue procesado, salgo
    }

    Uri uri = Uri.parse(link);
    String? status = uri.queryParameters['status'];

    // Actualizo el ultimo link procesado
    await prefs.setString('last_handled_link', link);

    //recupero el id de membresia
    final String? membresiaId = prefs.getString('pending_membresia_id');

    print(uri.queryParameters);
    //Ahora manejo segun el status del pago
    if(status == 'approved') {
      print('Pago exitoso');
      //tengo que setear la membresia
      final UserData userProvider = context.read<UserData>();
      if(membresiaId != null){
        await userProvider.updateMembresiaId(membresiaId);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago exitoso y membresía asignada')));
      await prefs.remove('pending_membresia_id');
      await prefs.remove('pending_payment_id');
      Navigator.pushReplacementNamed(context, '/home');
      
    } else if (status == 'pending') {
      print('Pago pendiente');
      String? payment_id = uri.queryParameters['payment_id'];
      final prefs = await SharedPreferences.getInstance();
      if(payment_id != null){
        await prefs.setString('pending_payment_id', payment_id);
      }
    } else if (status == 'failure') {
      print('Pago fallido');
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserData>().initializeData();
    final MembresiaProvider provider = context.read<MembresiaProvider>();
    final UserData userData = context.read<UserData>();
    return Scaffold(
      body: FutureBuilder(
        future: provider.getMembresiasOrigen(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final membresias = snapshot.data!;
            return userData.esBasico()
                ? MembresiaDisplayerBasico(membresias: membresias)
                : const MembresiaDisplayerPropietario();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al obtener las membresias'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: const FooterBottomNavigationBar(
        initialScreen: ScreenType.membresia,
      ),
    );
  }
}
