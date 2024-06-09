import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MembresiaDisplayerBasico extends StatefulWidget {
  const MembresiaDisplayerBasico({super.key});

  @override
  State<MembresiaDisplayerBasico> createState() =>
      _MembresiaDisplayerBasicoState();
}

class _MembresiaDisplayerBasicoState extends State<MembresiaDisplayerBasico> {
  late Map<String, dynamic> membresia = {};
  bool _isLoading = true; // Flag to track loading state

  @override
  void initState() {
    super.initState();
    getMembresia();
  }


  Future<String?> getMembresiaId() async {
    final userProvider = context.read<UserData>();
    try {
      final docRef = FirebaseFirestore.instance
          .collection('usuario')
          .doc(userProvider.userId);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        return userData['membresiaId'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void getMembresia() async {
    final String? membresiaId = await getMembresiaId();
    if (membresiaId != null) {
      try {
        final docRef =
            FirebaseFirestore.instance.collection('membresia').doc(membresiaId);
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          setState(() {
            membresia = snapshot.data() as Map<String, dynamic>;
            _isLoading = false; // Set loading to false after data is fetched
          });
        } else {
          setState(() {
            _isLoading = false; // Set loading to false even if no data found
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Set loading to false on error
        });
      }
    } else {
      setState(() {
        _isLoading = false; // Set loading to false if no membership ID found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Progress indicator while loading
          : membresia.isEmpty
              ? const Center(
                  child: Text(
                    "No tiene membresía disponible",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ) // Text for no membership
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nombre:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(membresia['nombreMembresia']),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Gimnasio:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(membresia['gimnasio']),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Costo:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${membresia['costo']} \$'),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Vencimiento:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(membresia['vencimiento']),
                    )
                  ],
                ),
    );
  }
}
