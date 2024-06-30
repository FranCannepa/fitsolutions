import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/inscription_provider.dart';
import 'package:fitsolutions/screens/Inscription/evaluation_detail_screen.dart';
import 'package:fitsolutions/screens/Inscription/evaluation_screen.dart';
import 'package:fitsolutions/screens/Inscription/form_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  String? gymId;
  bool hasError = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGymId();
  }

  Future<void> fetchGymId() async {
    try {
      final provider = Provider.of<InscriptionProvider>(context, listen: false);
      String? fetchedGymId = await provider.gymLoggedIn();
      if (fetchedGymId != null) {
        setState(() {
          gymId = fetchedGymId;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('INSCRIPCIONES'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError || gymId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('INSCRIPCIONES'),
        ),
        body: const Center(
          child: Text('Error fetching gym ID'),
        ),
      );
    }
    final inscriptionProvider = context.watch<InscriptionProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('INSCRIPCIONES'),
        ),
        body: FutureBuilder(
          future: Future.wait([
            inscriptionProvider.usuariosInscriptos(gymId!),
            inscriptionProvider.usuariosPendientes(gymId!),
            inscriptionProvider.getUnsubscribedUsers(gymId!),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              List<UsuarioBasico> subscribedUsers = snapshot.data![0];
              List<UsuarioBasico> pendingUsers = snapshot.data![1];
              List<UsuarioBasico> unsubscribedUsers = snapshot.data![2];
      
              return Container(
                color: Colors.grey[200], // Background color for the screen
                padding: const EdgeInsets.all(16.0), // General padding
                child: Column(
                  children: [
                    const SectionTitle(title: 'Inscriptos'),
                    ...subscribedUsers.map((user) => UserCard(
                          user: user,
                          gymId: gymId!,
                          isSubscribed: true,
                        )),
                    const SectionTitle(title: 'Inscripciones pendientes'),
                    ...pendingUsers.map((user) => UserCard(
                          user: user,
                          gymId: gymId!,
                          isSubscribed: false,
                          onComplete: () async {
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EvaluationFormScreen(
                                    gymId: gymId!,
                                    userId: user.docId,
                                  ),
                                ),
                              );
                            }
                          },
                        )),
                    const SectionTitle(title: 'No Inscriptos'),
                    ...unsubscribedUsers.map((user) => UserCard(
                          user: user,
                          gymId: gymId!,
                          isSubscribed: false,
                          onAddToPending: () async {
                            await inscriptionProvider.addUserToPending(
                                gymId!, user.docId);
                            await inscriptionProvider.addFormRequest(
                                gymId!, user.docId);
                          },
                        )),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No se encontraron Datos'));
            }
          },
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UsuarioBasico user;
  final String gymId;
  final bool isSubscribed;
  final VoidCallback? onComplete;
  final VoidCallback? onAddToPending;

  const UserCard({
    super.key,
    required this.user,
    required this.gymId,
    this.isSubscribed = false,
    this.onComplete,
    this.onAddToPending,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4.0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          user.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSubscribed)
              IconButton(
                icon: const Icon(Icons.assignment_ind_sharp),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EvaluationDetailsScreen(
                        gymId: gymId,
                        userId: user.docId,
                      ),
                    ),
                  );
                },
              ),
            if (!isSubscribed && onAddToPending == null) ...{
            IconButton(
              icon: const Icon(Icons.description),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormDetailsScreen(
                      ownerId: gymId,
                      userId: user.docId,
                    ),
                  ),
                );
              },
            ),
            },
            if (!isSubscribed && onComplete != null)
              ElevatedButton(
                onPressed: onComplete,
                child: const Text('Completar'),
              ),
            if (!isSubscribed && onAddToPending != null)
              ElevatedButton(
                onPressed: onAddToPending,
                child: const Text('Agregar a Pendiente'),
              ),
          ],
        ),
      ),
    );
  }
}
