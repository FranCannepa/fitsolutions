
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';


class FitnessRepository {
  Logger log = Logger();

  final planCollection = FirebaseFirestore.instance.collection('plan');


  //Get

  Stream<QuerySnapshot> getPlanes(){
    return planCollection.snapshots();
  }

  //Add
  Future<void> addPlan(String name) async{
    planCollection.add({'name':name});
  }

  Future<void> updatePlan(String docId, String newName) async {
     planCollection.doc(docId).update({
      'name': newName,
    });
  }

  Future<void> deletePlan(String docId) async{
     planCollection.doc(docId).delete();
  }

}