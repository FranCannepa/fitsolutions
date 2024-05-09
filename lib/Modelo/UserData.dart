import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String userId = '';
  String username = '';
  String email = '';
  String docId = '';

  void updateUserData(Map<String, dynamic> userData) {
    userId = userData['id'];
    username = userData['username'];
    email = userData['email'];
    docId = userData['docId'];
    notifyListeners();
  }
}
