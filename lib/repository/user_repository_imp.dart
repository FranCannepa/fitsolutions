
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/repository/user_repository.dart';
import 'package:logger/logger.dart';


class UserRepositoryImp extends UserRepository {
  Logger log = Logger();
  final FirebaseAuth _firebaseAuth;
  final userCollection = FirebaseFirestore.instance.collection('usuario');

  UserRepositoryImp({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<void> logOut() async {
    try{
      await _firebaseAuth.signOut();
    }
    on FirebaseAuthException catch (e){
      log.t(e);
    }
  }

}
