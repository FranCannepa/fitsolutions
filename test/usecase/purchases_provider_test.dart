import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsolutions/providers/purchases_provider.dart';



void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PurchasesProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    provider = PurchasesProvider(fakeFirestore);
  });

  group('PurchasesProvider Tests', () {
    test('addPurchase adds a new purchase', () async {
      final purchaseData = {'productId': 'prod1', 'usuarioId': 'user1', 'amount': 100};

      await provider.addPurchase(purchaseData);

      final snapshot = await fakeFirestore.collection('purchases').get();
      expect(snapshot.docs.length, 1);
      final purchase = snapshot.docs.first.data();
      expect(purchase['productId'], 'prod1');
      expect(purchase['usuarioId'], 'user1');
      expect(purchase['amount'], 100);
    });

    test('getPurchasesByUser returns user purchases', () async {
      await fakeFirestore.collection('purchases').add({'productId': 'prod1', 'usuarioId': 'user1', 'amount': 100});
      await fakeFirestore.collection('purchases').add({'productId': 'prod2', 'usuarioId': 'user1', 'amount': 200});

      final purchases = await provider.getPurchasesByUser('user1');

      expect(purchases.length, 2);
      expect(purchases[0]['productId'], 'prod1');
      expect(purchases[1]['productId'], 'prod2');
    });

    test('getPurchasesByGym returns gym purchases', () async {
      final membresia1 = await fakeFirestore.collection('membresia').add({'origenMembresia': 'gym1'});
      final membresia2 = await fakeFirestore.collection('membresia').add({'origenMembresia': 'gym1'});

      await fakeFirestore.collection('purchases').add({'productId': membresia1.id, 'usuarioId': 'user1', 'amount': 100});
      await fakeFirestore.collection('purchases').add({'productId': membresia2.id, 'usuarioId': 'user2', 'amount': 200});

      final purchases = await provider.getPurchasesByGym('gym1');

      expect(purchases.length, 2);
      expect(purchases[0]['productId'], membresia1.id);
      expect(purchases[1]['productId'], membresia2.id);
    });

    test('updatePurchaseStatus updates the status of a purchase', () async {
      final purchaseRef = await fakeFirestore.collection('purchases').add({'productId': 'prod1', 'usuarioId': 'user1', 'amount': 100, 'status': 0});

      final result = await provider.updatePurchaseStatus(purchaseRef.id, 1);

      expect(result, true);
      final updatedDoc = await fakeFirestore.collection('purchases').doc(purchaseRef.id).get();
      expect(updatedDoc.data()!['status'], 1);
    });

    test('deletePurchase deletes a purchase', () async {
      final purchaseRef = await fakeFirestore.collection('purchases').add({'productId': 'prod1', 'usuarioId': 'user1', 'amount': 100});

      final result = await provider.deletePurchase(purchaseRef.id);

      expect(result, true);
      final deletedDoc = await fakeFirestore.collection('purchases').doc(purchaseRef.id).get();
      expect(deletedDoc.exists, false);
    });

    test('getStatusName returns the status name', () async {
      await fakeFirestore.collection('statusIds').add({'id': 'status1', 'nombre': 'Active'});

      final statusName = await provider.getStatusName('status1');

      expect(statusName, 'Active');
    });

    test('getStatusName returns unknown status if not found', () async {
      final statusName = await provider.getStatusName('unknownStatus');

      expect(statusName, 'Unknown status');
    });
  });
}
