import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/repository/user_repository.dart';
import 'package:fitsolutions/screens/Home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'sign_out_widget_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserProvider>()])
void main() {
  UserProvider provider = MockUserProvider();

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
    testWidgets('Sign out pressed', (WidgetTester tester) async {
      when(provider.signOut()).thenAnswer((_) async => Future.value(null));

      await tester.pumpWidget(makeTestable(const HomeScreen()));
      await tester.tap(signOutButton);
      await tester.pump();
      verify(provider.signOut()).called(1);
    });
  });
}
