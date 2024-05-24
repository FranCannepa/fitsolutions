import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/repository/fitness_repository.dart';
import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final FitnessRepository fitnessRepository = FitnessRepository();
  final TextEditingController textController = TextEditingController();

  void openNoteBox(String? docId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docId == null) {
                        fitnessRepository.addPlan(textController.text);
                      } else {
                        fitnessRepository.updatePlan(
                            docId, textController.text);
                      }
                      textController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Add'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planes')),
      floatingActionButton: ElevatedButton(
        onPressed: () => openNoteBox(null), //placeholder
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fitnessRepository.getPlanes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List planesList = snapshot.data!.docs;
            return ListView.builder(
                itemCount: planesList.length,
                itemBuilder: (context, index) {
                  //get indiviual
                  DocumentSnapshot doc = planesList[index];
                  String docId = doc.id;

                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  String planName = data['name'];

                  return ListTile(
                    title: Text(planName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () => openNoteBox(docId),
                            icon: const Icon(Icons.settings)),
                        IconButton(
                            onPressed: () => fitnessRepository.deletePlan(docId),
                            icon: const Icon(Icons.delete)),
                      ],
                    ),
                  );
                  //get note from each doc
                  //display
                });
          } else {
            return const Text('No hay planes');
          }
        },
      ),
    );
  }
}
