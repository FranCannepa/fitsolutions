import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/providers/inscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserListRutina extends StatefulWidget {
  final FitnessProvider fitnessProvider;
  final String planId;
  const UserListRutina(
      {super.key, required this.fitnessProvider, required this.planId});

  @override
  State<UserListRutina> createState() => _UserListRutinaState();
}

class _UserListRutinaState extends State<UserListRutina> {
  List<UsuarioBasico> allUsers = [];
  List<UsuarioBasico> filteredUsers = [];
  List<UsuarioBasico> selectedUsers = [];
  List<UsuarioBasico> asignarUsers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  Future<void> fetchUsers() async {
    final insProvider = context.read<InscriptionProvider>();
    String? gymId = await insProvider.gymLoggedIn();
    List<UsuarioBasico> users = await insProvider.usuariosInscriptos(gymId!);
    List<UsuarioBasico> enRutina =
        await widget.fitnessProvider.getUsuariosEnRutina(widget.planId);

    setState(() {
      allUsers = users;
      filteredUsers = users;
      selectedUsers = enRutina;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void filterUsers(String query) {
    final filtered = allUsers
        .where((user) => user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredUsers = filtered;
    });
  }

  void onUserSelected(bool? isSelected, UsuarioBasico user) {
    setState(() {
      if (isSelected == true) {
        asignarUsers.add(user);
      } else {
        asignarUsers.remove(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FitnessProvider>();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.50,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por Email',
                  border: OutlineInputBorder(),
                ),
                onChanged: filterUsers,
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final inFireStore = selectedUsers
                      .any((selectedUser) => selectedUser.docId == user.docId);
                  final inSelected = asignarUsers
                      .any((selectedUser) => selectedUser.docId == user.docId);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Theme.of(context).primaryColor
                    ),
                    child: ListTile(
                      title: Text(user.nombreCompleto),
                      subtitle: Text(user.email),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                              message: inFireStore
                              ? 'Usuario tiene rutina'
                              : 'Seleccionado para rutina',
                            child: Checkbox(
                              value: inFireStore || inSelected,
                              onChanged: (bool? value) {
                                onUserSelected(value, user);
                              },
                              activeColor:
                                  inFireStore ? Colors.green : Colors.orange,
                              checkColor: Colors.white,
                            ),
                          ),
                          IconButton(
                              onPressed: () async => {
                                    await provider.removeUsuarioDeRutina(
                                        widget.planId, user.docId),
                                    fetchUsers(),
                                  },
                              icon: const Icon(Icons.remove_circle_outline)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await provider.addUsuarioARutina(widget.planId, asignarUsers);
                asignarUsers = [];
                fetchUsers();
              },
              child: const Text('AGREGAR RUTINA '),
            ),
          ],
        ),
      ),
    );
  }
}
