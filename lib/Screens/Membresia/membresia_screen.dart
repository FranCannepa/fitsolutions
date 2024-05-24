import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:fitsolutions/Screens/Home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<Map<String, dynamic>> getMembershipInfo() async {
  return {
    'nombre': 'John Doe',
    'gimnasio': 'Gimnasio Vida Sana',
    'costo': 5000,
    'vencimiento': DateTime.now().add(Duration(days: 30)),
  };
}

class MembresiaScreen extends StatefulWidget {
  const MembresiaScreen({Key? key}) : super(key: key);

  @override
  _MembresiaScreenState createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen> {
  late Future<Map<String, dynamic>> _membershipInfo;

  @override
  void initState() {
    super.initState();
    _membershipInfo = getMembershipInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membresia'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _membershipInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final membershipData = snapshot.data!;
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nombre:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(membershipData['nombre']),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Gimnasio:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(membershipData['gimnasio']),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Costo:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(membershipData['costo'].toString() + ' \$'),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Vencimiento:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy')
                        .format(membershipData['vencimiento']),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar:
          const FooterBottomNavigationBar(),
    );
  }
}
