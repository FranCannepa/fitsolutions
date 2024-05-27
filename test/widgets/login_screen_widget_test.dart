import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Home/home_screen.dart';
import 'package:fitsolutions/screens/Login/forgot_password_screen.dart';
import 'package:fitsolutions/screens/Login/login_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../usecase/user_provider_test.mocks.dart';

void main() {
  MockFirebaseAuth mockAuth = MockFirebaseAuth();
  FakeFirebaseFirestore mockStore = FakeFirebaseFirestore();
  StreamController<User?> authStateController = StreamController<User?>();
  when(mockAuth.authStateChanges())
      .thenAnswer((_) => authStateController.stream);
  UserProvider provider =
      UserProvider(firebaseAuth: mockAuth, firestore: mockStore);
  // NavigationService mockNavigationService = NavigationService.instance;
  final MockUserCredential mockUser = MockUserCredential();

  Widget makeTestable(Widget child) {
    return ChangeNotifierProvider<UserProvider>.value(
        value: provider,
        child: MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          home: Scaffold(
            body: child,
          ),
          routes: <String, WidgetBuilder>{
            '/home': (BuildContext context) => const HomeScreen()
          },
        ));
  }

  testWidgets('Login form widget test', (WidgetTester tester) async {
    await mockStore.collection('usuario').add({'email': 'test@test.com'});
    await tester
        .pumpWidget(makeTestable(LoginEmailScreen(userProvider: provider)));
    // Verify initial state
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesion'), findsOneWidget);
    expect(find.byKey(const Key('Restablecer')), findsOneWidget);
    //expect(find.text('Continuar con Google'), findsOneWidget);

    // Enter valid email and password
    await tester.enterText(find.byType(MyTextField).first, 'test@example.com');
    await tester.enterText(find.byType(MyTextField).last, 'password123');
    await tester.pump();

    // Tap the login button
    await tester.tap(find.text('Iniciar Sesion'));
    await tester.pump();
    when(mockAuth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password123')).thenAnswer((_) async => mockUser);
    when(provider.signIn('test@example.com','password123')).thenAnswer((_) async => mockUser);

    SharedPreferences.setMockInitialValues({});
    // Verify signIn was called
    verify(provider.signIn('test@example.com', 'password123')).called(1);

    // Verify navigation to home screen
    //verify(mockNavigationService.pushNamed("/home")).called(1);

    // Verify SnackBar is shown on error
    when(provider.signIn('test@example.com', 'password123')).thenThrow(Exception('Login failed'));
    await tester.tap(find.text('Iniciar Sesion'));
    await tester.pump();

    expect(find.text('Error al intentar Iniciar Sesion'), findsOneWidget);

    // Verify navigation to ForgotPasswordScreen
    await tester.tap(find.byKey(const Key('Restablecer')));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });
}
