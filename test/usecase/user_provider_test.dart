import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'user_provider_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserProvider>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<User>(),
  MockSpec<UserCredential>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<CollectionReference>(),
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late UserProvider userProvider;

  setUpAll(() async {
    //Initiliaze firebase for test
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();

    userProvider = UserProvider(firebaseAuth: mockFirebaseAuth);
  });

  group('UserProvider', () {
    test('signUp succeeds', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('123');
      when(mockFirestore.collection('users'))
          .thenReturn(MockCollectionReference());

      await userProvider.signUp('test@test.com', 'password');
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .called(1);
    });

    test('signUp fails', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenThrow(FirebaseAuthException(code: 'weak-password'));

      expect(
        userProvider.signUp('test@test.com', 'password'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
    test('signIn succeeds', () async {
      when(MockFirebaseAuth().signInWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => mockUserCredential);

      expect(userProvider.signIn('test@test.com', 'password'), completes);
    });

    test('signIn fails', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
        userProvider.signIn('test@test.com', 'password'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('resetPassword succeeds', () async {
      const email = 'test@test.com';

      when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
          .thenAnswer((_) async {});

      await userProvider.resetPassword(email);

      verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
    });

    test('resetPassword throws an exception on failure', () async {
      // Arrange
      const email = 'test@example.com';
      final exception = FirebaseAuthException(code: 'user-not-found');

      when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
          .thenThrow(exception);

      // Act & Assert
      expect(() => userProvider.resetPassword(email),
          throwsA(isA<FirebaseAuthException>()));
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
    });
  });
}
