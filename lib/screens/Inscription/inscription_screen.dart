import 'package:fitsolutions/Utilities/modal_utils.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
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
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

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

  void _filterUsers() {
    setState(() {
      searchQuery = searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: const Text(
            'Inscripciones',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError || gymId == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: const Text(
            'Inscripciones',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: const Text(
            'Inscripciones',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
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

              // Filter users based on the search query
              List<UsuarioBasico> filteredSubscribedUsers = subscribedUsers
                  .where((user) => user.email
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();
              List<UsuarioBasico> filteredPendingUsers = pendingUsers
                  .where((user) => user.email
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();
              List<UsuarioBasico> filteredUnsubscribedUsers = unsubscribedUsers
                  .where((user) => user.email
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();

              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Add the search bar here
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar por correo electrónico',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _filterUsers,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Inscriptos'),
                      ...filteredSubscribedUsers.map((user) => UserCard(
                            user: user,
                            gymId: gymId!,
                            isSubscribed: true,
                          )),
                      const SectionTitle(title: 'Inscripciones pendientes'),
                      ...filteredPendingUsers.map((user) => UserCard(
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
                      ...filteredUnsubscribedUsers.map((user) => UserCard(
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
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.black,
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
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 4.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
              Row(
                children: [
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
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final provider = context.read<InscriptionProvider>();
                      await provider.allowModification(user.docId, gymId);
                      if (context.mounted) {
                        ModalUtils.showSuccessModal(
                            context,
                            'Modificacion Autorizada',
                            ResultType.success,
                            () => Navigator.pop(context));
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      final provider = context.read<InscriptionProvider>();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Confirmar eliminación',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          content: const Text(
                            '¿Está seguro de que desea eliminar la inscripcion?',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await provider.borrarInscripcion(
                                    user.docId, gymId);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            if (onAddToPending == null)
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
