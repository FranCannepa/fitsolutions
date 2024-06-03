import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/Plan/plan_create_dialogue.dart';
import 'package:fitsolutions/screens/Plan/plan_info_screen.dart';
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
              title: const Text('Planes'), backgroundColor: Colors.amber),
          floatingActionButton: ElevatedButton(
            onPressed: () => openNoteBox(null, fitnessProvider),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20), // Adjust padding as needed
              backgroundColor: Colors.orange,
              elevation: 8, // Add shadow by setting elevation
              shadowColor: Colors.black.withOpacity(0.8),
            ), //placeholder
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: FutureBuilder<List<Plan>>(
              future: fitnessProvider.getPlanesList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No plans found.'));
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
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              plan.name.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                              .elementAt(0)
                                              .value,
                                          maxHeightController.text = plan
                                              .height.entries
                                              .elementAt(1)
                                              .value,
                                          openNoteBox(
                                              plan.planId, fitnessProvider)
                                        },
                                    icon: const Icon(Icons.settings)),
                                IconButton(
                                    onPressed: () =>
                                        fitnessProvider.deletePlan(plan.planId),
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
