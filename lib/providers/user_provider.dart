import 'package:fitsolutions/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserProvider extends ChangeNotifier{
  Logger log = Logger();
  final UserRepository _userRepository;

  UserProvider({required UserRepository userRepository}) : _userRepository = userRepository;

  
  Future<void> signOut() async{
    try{
    _userRepository.logOut();
    }
    catch(e){
      log.i('couldnt log out');
    }
  }
}