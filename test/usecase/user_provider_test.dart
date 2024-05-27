import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'user_provider_test.mocks.dart';

@GenerateMocks([FirebaseAuth,UserCredential,User])

void main() {
  MockFirebaseAuth mockAuth = MockFirebaseAuth();
  FakeFirebaseFirestore mockStore = FakeFirebaseFirestore();
  StreamController<User?> authStateController = StreamController<User?>();

  when(mockAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);
  UserProvider userProvider = UserProvider(firebaseAuth: mockAuth,firestore: mockStore);

  setUpAll(() async {
    //Initiliaze firebase for test
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('UserProvider', () {
    test('INICIAR SESION SUCCESS', () async{
            // Mock FirebaseAuth signInWithEmailAndPassword
      await mockStore.collection('usuario').add({
        'email': 'test@test.com',
      });

      final MockUserCredential mockUser = MockUserCredential();
      when(mockAuth.signInWithEmailAndPassword(
              email: 'test@test.com', password: anyNamed('password')))
          .thenAnswer((_) async => mockUser);

      SharedPreferences.setMockInitialValues({});
      await userProvider.signIn('test@test.com', 'password123');

      verify(mockAuth.signInWithEmailAndPassword(email: 'test@test.com', password: 'password123')).called(1);

      expect(await userProvider.pref.getEmail(), 'test@test.com');
    });

    test('INICIAR SESION FAILURE EXCEPTION', () async{
            await mockStore.collection('usuario').add({
        'email': 'test@test.com',
      });

      when(mockAuth.signInWithEmailAndPassword(email: 'test@test.com', password: 'wrong_password')).thenThrow(FirebaseAuthException(code: 'error-password'));
      SharedPreferences.setMockInitialValues({});

      expect(() async => await userProvider.signIn('test@test.com', 'wrong_password'),throwsA(isA<FirebaseAuthException>()));
    });

    test('REGISTRO SUCCESS', () async {
          final MockUserCredential mockCredential = MockUserCredential();
          when(mockAuth.createUserWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => mockCredential);

      await userProvider.signUp('test@test.com', 'password');
      verify(mockAuth.createUserWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .called(1);
    });

    test('REGISTRO FAILURE', () async {
      when(mockAuth.createUserWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenThrow(FirebaseAuthException(code: 'weak-password'));

      expect(
        userProvider.signUp('test@test.com', 'password'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('RESET PASSWORD SUCCESS', () async {
      const email = 'test@test.com';

      when(mockAuth.sendPasswordResetEmail(email: email))
          .thenAnswer((_) async {});
      SharedPreferences.setMockInitialValues({});
      await userProvider.resetPassword(email);

      verify(mockAuth.sendPasswordResetEmail(email: email)).called(1);
    });

    test('SIGN OUT SUCCESS', () async{
      when(mockAuth.signOut()).thenAnswer((_) async {});
            SharedPreferences.setMockInitialValues({});
      await userProvider.signOut();

      // Assert: Verify that signOut was called once
      verify(mockAuth.signOut()).called(1);
    });

    test('SIGN OUT', () async {
      // Arrange: Stub the signOut method to throw an exception
      when(mockAuth.signOut())
          .thenThrow(FirebaseAuthException(code: 'sign-out-failed'));
      SharedPreferences.setMockInitialValues({});
      // Act & Assert: Call the signOut method and expect an exception
      expect(
        userProvider.signOut(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    
  });
}
