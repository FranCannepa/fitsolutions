import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchasesProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPurchase(Map<String, dynamic> purchaseData) async {
    try {
      await _db.collection('purchases').add(purchaseData);
      notifyListeners();
    } catch (e) {
      print('Error adding purchase: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPurchasesByUser(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('purchases')
          .where('usuarioId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching purchases: $e');
      return [];
    }
  }

  Future<bool> updatePurchaseStatus(String purchaseId, int newStatus) async {
    try {
      final docRef = _db.collection('purchases').doc(purchaseId);
      await docRef.update({'status': newStatus});
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating purchase status: $e');
      return false;
    }
  }

  Future<bool> deletePurchase(String purchaseId) async {
    try {
      final docRef = _db.collection('purchases').doc(purchaseId);
      await docRef.delete();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting purchase: $e');
      return false;
    }
  }
}
