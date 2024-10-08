import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/Plan/plan_create_dialogue.dart';
import 'package:fitsolutions/screens/Plan/plan_info_screen.dart';
import 'package:fitsolutions/screens/Plan/user_list_rutina.dart';
import 'package:fitsolutions/screens/rutina_basico/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController minWeightController = TextEditingController();
  final TextEditingController maxWeightController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController minHeightController = TextEditingController();

  void openNoteBox(String? docId, FitnessProvider fitnessProvider) {
    showDialog(
      context: context,
      builder: (context) => PlanCreateDialogue(
          fitnessProvider: fitnessProvider,
          docId: docId,
          nameController: nameController,
          descController: descController,
          minWeightController: minWeightController,
          maxWeightController: maxWeightController,
          maxHeightController: minHeightController,
          minHeightController: maxHeightController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FitnessProvider fitnessProvider = context.watch<FitnessProvider>();
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
              'Rutinas',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => openNoteBox(null, fitnessProvider),
            child:
                Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
          ),
          body: FutureBuilder<List<Plan>>(
              future: fitnessProvider.getPlanesList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child:
                          NoDataError(message: 'Aun no se han creado Rutinas'));
                } else {
                  final plans = snapshot.data!;

                  return ListView.builder(
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              plan.name.toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).cardColor),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => UserListRutina(
                                        fitnessProvider: fitnessProvider,
                                        planId: plan.planId),
                                  ),
                                  icon: const Icon(Icons.person_add),
                                ),
                                IconButton(
                                    onPressed: () => {
                                          nameController.text = plan.name,
                                          descController.text =
                                              plan.description,
                                          minWeightController.text = plan
                                              .weight.entries
                                              .elementAt(0)
                                              .value,
                                          maxWeightController.text = plan
                                              .weight.entries
                                              .elementAt(1)
                                              .value,
                                          minHeightController.text = plan
                                              .height.entries
                                              .elementAt(1)
                                              .value,
                                          maxHeightController.text = plan
                                              .height.entries
                                              .elementAt(0)
                                              .value,
                                          openNoteBox(
                                              plan.planId, fitnessProvider)
                                        },
                                    icon: const Icon(Icons.settings)),
                                IconButton(
                                    onPressed: () => {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ConfirmDialog(
                                                    title: 'Borrar Rutina',
                                                    content:
                                                        '¿Borrar la Rutina?',
                                                    onConfirm: () async {
                                                      fitnessProvider
                                                          .deletePlan(
                                                              plan.planId);
                                                    },
                                                    parentKey: null);
                                              })
                                        },
                                    icon: const Icon(Icons.delete)),
                              ],
                            ),
                            onTap: () => {
                              showModalBottomSheet<void>(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return PlanInfoScreen(
                                      plan: plan,
                                      fitnessProvider: fitnessProvider);
                                },
                              ),
                            },
                          ),
                        );
                      });
                }
              })),
    );
  }
}
