import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/register_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../usecase/user_provider_test.mocks.dart';

class MockUserCredential extends Mock implements UserCredential {}
void main(){
    MockFirebaseAuth mockAuth = MockFirebaseAuth();
    FakeFirebaseFirestore mockStore = FakeFirebaseFirestore();
    StreamController<User?> authStateController = StreamController<User?>();
    when(mockAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);
    UserProvider provider = UserProvider(firebaseAuth:mockAuth,firestore: mockStore);
    UserData data = UserData();
    MockUserCredential mockUserCredential = MockUserCredential();
    
    Widget buildTestableWidget(Widget widget) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserData>(create: (_) => data),
          Provider<UserProvider>(create: (_) => provider),
        ],
        child: MaterialApp(
          home: Scaffold(body: widget),
        ),
      );
    }
  
  testWidgets('Register widget test', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(RegisterEmailScreen(userProvider: provider)));
    // Perform tests

    // Test initial state
    expect(find.text('Registrarme'), findsOneWidget);
    expect(find.byType(MyTextField), findsNWidgets(3));

    // Test invalid email
    await tester.enterText(find.byType(MyTextField).at(0), 'invalid email');
    await tester.tap(find.text('Registrarme'));
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Test valid email
    await tester.enterText(find.byType(MyTextField).at(0), 'test@example.com');
    await tester.tap(find.text('Registrarme'));
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsNothing);

    // Test password validation
    await tester.enterText(find.byType(MyTextField).at(1), 'short');
    await tester.tap(find.text('Registrarme'));
    await tester.pump();
    expect(find.text('Porfavor ingresa una contraseña valida'), findsOneWidget);

    // Test valid password
    await tester.enterText(find.byType(MyTextField).at(1), 'ValidPassword1!');
    await tester.tap(find.text('Registrarme'));
    await tester.pump();
    expect(find.text('Porfavor ingresa una contraseña valida'), findsNothing);

    // Test confirm password
    await tester.enterText(find.byType(MyTextField).at(2), 'ValidPassword1!');
    await tester.tap(find.text('Registrarme'));
    await tester.pump();
    expect(find.text('Porfavor ingresa una contraseña valida'), findsNothing);
    expect(find.text('Las contraseñas no coiniciden'), findsNothing);

    // Test passwords do not match
    await tester.enterText(find.byType(MyTextField).at(2), 'DifferentPassword1!');
    await tester.tap(find.text('Registrarme'));
    await tester.pump(Durations.short4);
    expect(find.byType(SnackBar), findsOneWidget);
    
    when( mockAuth.createUserWithEmailAndPassword(email: 'test@example.com', password: 'ValidPassword1!')).thenAnswer((_) => Future.value(mockUserCredential));
    await tester.enterText(find.byType(MyTextField).at(2), 'ValidPassword1!');
    await tester.tap(find.text('Registrarme'));
    await tester.pump();
    expect(find.text('Error al registrarse'), findsNothing);

  });
}