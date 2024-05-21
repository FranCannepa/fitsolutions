import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/repository/user_repository.dart';
import 'package:fitsolutions/screens/Home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockUserProvider extends Mock implements UserProvider {
  final MockUserRepository repository;
  MockUserProvider({required this.repository});
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserRepository extends Mock implements UserRepository {
  final MockFirebaseAuth auth;
  MockUserRepository({required this.auth});
}


void main() {
  MockFirebaseAuth auth = MockFirebaseAuth();
  MockUserRepository repository = MockUserRepository(auth: auth);
  MockUserProvider provider = MockUserProvider(repository: repository);

  Widget makeTestable(Widget child) {
    return ChangeNotifierProvider<UserProvider>.value(
        value: provider,
        child: MaterialApp(
          home: child,
        ));
  }

  var signOutButton = find.byKey(const Key('sign_out'));

  group('Sign out screen test', () {
    testWidgets('Sign out button is found', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const HomeScreen()));
      expect(signOutButton, findsOneWidget);
    });
  });
}
