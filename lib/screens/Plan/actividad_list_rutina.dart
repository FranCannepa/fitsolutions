import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActividadListRutina extends StatefulWidget {
  final FitnessProvider fitnessProvider;
  final String planId;
  const ActividadListRutina({super.key, required this.fitnessProvider, required this.planId});

  @override
  State<ActividadListRutina> createState() => _ActividadListRutinaState();
}

class _ActividadListRutinaState extends State<ActividadListRutina> {
  List<UsuarioBasico> allActivities = [];
  List<UsuarioBasico> filteredActivities = [];
  List<UsuarioBasico> selectedActivity = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  
  Future<void> fetchUsers() async {
    List<UsuarioBasico> users = await widget.fitnessProvider.getUsuariosInscriptos(widget.planId);
    List<UsuarioBasico> enRutina = await widget.fitnessProvider.getUsuariosEnRutina(widget.planId);
    setState(() {
      allActivities = users;
      filteredActivities = users;
      selectedActivity = enRutina;
      isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void filterUsers(String query) {
    final filtered = allActivities
        .where((user) => user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredActivities = filtered;
    });
  }

  void onUserSelected(bool? isSelected, UsuarioBasico user) {
    setState(() {
      if (isSelected == true) {
        selectedActivity.add(user);
      } else {
        selectedActivity.remove(user);
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por Nombre',
                  border: OutlineInputBorder(),
                ),
                onChanged: filterUsers,
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredActivities.length,
                itemBuilder: (context, index) {
                  final user = filteredActivities[index];
                  return ListTile(
                    title: Text(user.nombreCompleto),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: selectedActivity.any((selectedUser) => selectedUser.docId == user.docId),
                          onChanged: (bool? value) {
                              onUserSelected(value, user);
                          },
                        ),
                        IconButton(onPressed: () async => {
                          await provider.removeUsuarioDeRutina(widget.planId, user.docId),
                          fetchUsers(),
                        },
                        icon: const Icon(Icons.remove_circle_outline)),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async{
                await provider.addUsuarioARutina(widget.planId, selectedActivity);
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