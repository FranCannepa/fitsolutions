import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../usecase/user_provider_test.mocks.dart';


void main(){
    MockFirebaseAuth mockAuth = MockFirebaseAuth();
    FakeFirebaseFirestore mockStore = FakeFirebaseFirestore();
    StreamController<User?> authStateController = StreamController<User?>();
    when(mockAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);
    UserProvider provider = UserProvider(firebaseAuth:mockAuth,firestore: mockStore);
    
    Widget makeTestable(Widget child) {
    return ChangeNotifierProvider<UserProvider>.value(
        value: provider,
        child: MaterialApp(
          home: child,
        ));
  }
  
  testWidgets('Reset password widget test', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestable(const ForgotPasswordScreen()));

    expect(find.text('Te enviaremos un email para restablecer tu contraseña'), findsOneWidget);
    expect(find.byType(MyTextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Enter valid email
    await tester.enterText(find.byType(MyTextField), 'test@example.com');
    await tester.pump();

    // Tap the reset button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

  // Verify resetPassword was called
    verify(provider.resetPassword('test@example.com')).called(1);

  // Verify SnackBar is shown
    expect(find.text('Se envio un email para restablecer su contraseña'), findsOneWidget);
  });
}